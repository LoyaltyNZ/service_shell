########################################################################
# File::    effective_date_class.rb
# (C)::     Loyalty New Zealand 2015
#
# Purpose:: Back-end generator for the "effective_date.rb" command line
#           tool. More documentation included inside the source file.
#           This class is separate from "effective_date.rb" to allow
#           easy testing without the risk of command line options to
#           "rspec" reaching Thor and being used by the generator too.
# ----------------------------------------------------------------------
#           13-Nov-2015 (ADH): Split from DAM's "effective_date.rb".
########################################################################

##############################################################################################
#
#                          CURRENTLY ONLY POSTGRESQL IS SUPPORTED!!
#
##############################################################################################

require "active_record"
require "thor" # a command line and file generator gem, see: https://github.com/erikhuda/thor

# Generators to create migrations to prepare a model to be effective dated.
#
# Prerequisites:
#
#   * The table at +table_name+ must contain timestamp columns called +updated_at+ and
#     +created_at+
#
#   * The value in the column must be set in application code (ActiveRecord timestamps
#     do this automagically) when the record is updated.
#
# By default the generators will create three migration files (each prefixed by
# a datetime and postfixed by the table name):
#
#   * create_trigger_function_for  A PostgreSQL specific migration to create the database
#                                  function which will be used by the trigger.  More
#                                  details can be found at #create_trigger_function_migration.
#
#   * add_trigger_to               A PostgreSQL specific migration to add a trigger to
#                                  the table named in +table_name+ which uses above
#                                  created funtion.
#
#   * create_history_table_for     A mixed PostgreSQL and ActiveRecord migration which creates
#                                  the history table named +table_name+_history_entries.  It
#                                  also adds an exclude constraint via a gist index to prevent
#                                  the creation of start and end date ranges which overlap
#                                  for a particular uuid.
#
# To run the generator, from the command line in the projects root directory:
#
#   bin/generators/effective_date.rb +table_name+ +column_1+ +column_2+ ... +column_n+
#
#   where:
#
#     +table_name+    The name of the table to add the columns, constraints, indexes
#                     and trigger to.
#
#     +column_1...n+  The names of the columns which represent the "data" portion of
#                     the table; "created_at" and "updated_at" are always included
#                     implicitly, though it is harmless to list them explicitly as
#                     parameters too.
#
# For example for a table with the below structure:
#
#  Product
#    id         int
#    name       string
#    cost       money
#    desc       text
#    updated_at timestamp
#    created_at timestamp
#
# The command to generate the migrations would be:
#
#    bin/generators/effective_date.rb products name cost desc
#
#
module Generators

  # Table names longer than this run the risk of having the name of the trigger function
  # truncated. Max length is 62 before truncation happens on constraints or the names of
  # functions. An error will be raised if a table name is longer then 63 chars.
  #
  # The longest base name of these database objects is the function name (see
  # the #function_base_name method) which is 15 chars.
  #
  MAX_TABLE_NAME_LENGTH = 47

  class EffectiveDate < Thor::Group
    include Thor::Actions

    # The first argument on the command line, the name of the table as it is in the database
    argument :table_name, :type => :string

    # The 2...n argument(s) on the command line, the name of the data columns of +table_name+
    argument :column_names, :type => :array

    def self.source_root
      File.join( File.dirname( __FILE__ ), '..' )
    end

    # Raises:
    #
    #    +TableNameLengthExceeded+        When the length of the table is
    #                                     greater then MAX_TABLE_NAME_LENGTH.
    #                                     This is to ensure that any constraint
    #                                     name is not truncated
    #
    def initialize(*args, &block)
      super

      if @table_name.length > MAX_TABLE_NAME_LENGTH
        raise TableNameLengthExceeded
      end

      @column_names << 'created_at' << 'updated_at'
      @column_names.uniq!
    end

    # Creates a migration file which, when run, will create a PostgreSQL function to be
    # used as a before update/insert/delete trigger on an effective dated table.
    #
    # During an update or delete action the behaviour is the same.  The values in the
    # columns defined in +column_names+ from the primary table before the action
    # (update/delete) will be inserted as a new record into the history table.
    #
    # This newly inserted record will have its +effective_start+ set.  If the current
    # action is an update, and this is the very first update, or if the action is a delete,
    # this value is set to the +created_at+ value (before the update actually happens) of
    # the record being updated.  If the action is an update and it is not the first time this
    # record has been updated (there exist history entries for this record) then the
    # +effective_start+ date will be set to maximum +effective_end+ from the history table
    # for the group (all history records with the same uuid).
    #
    # During an update action the +effective_end+ will be set to the updating record's
    # new +updated_at+ value.
    #
    # During a delete action the +effective_end+ will be set to +now()::timestamp+ (the
    # current timestamp as reported by the database).
    #
    # During an update validation will be preformed to ensure the value of
    # +effective_end+ being inserted into the history table will be greater than all other
    # values for the same +uuid+.  If not an error will be returned/thrown.
    #
    # During an insert there will be no alterations to history table.  There will,
    # however, be a check run to ensure that the uuid of the record being inserted into
    # the primary table (assumed to be the +id+ column) does not yet exist.  If this
    # value does exist an error will be raised.
    #
    def create_trigger_function_migration
      base_name = Utils.migration_function_base_name
      filename  = Utils.migration_file_name( base_name, table_name )
      config    = {
                    :function_base_name => Utils.function_base_name,
                    :migration_class    => Utils.migration_class_name( base_name ,table_name )
                  }

      template('templates/effective_date/create_trigger_function.tt', filename, config)
    end

    # Creates a migration which, when run, creates a before update, delete or insert trigger
    # on the table +table_name+.
    #
    # Only changes to the values of columns defined in +column_names+ will cause this trigger
    # to fire during an update.
    #
    def create_trigger_migration
      base_name = Utils.migration_trigger_base_name
      filename  = Utils.migration_file_name( base_name, table_name )
      config    = {
                    :function_base_name => Utils.function_base_name,
                    :migration_class    => Utils.migration_class_name( base_name ,table_name )
                  }

      template('templates/effective_date/create_trigger.tt', filename, config)
    end

    # Creates a migration file to create a history table:
    #
    # +table_name+_history_entries
    #
    # This table will have the below layout:
    #
    #    +id+::                This will be a concatenation of +uuid+_+effective_end+
    #
    #    +uuid+::              This will be the actual uuid of the resource instance.
    #                          It is expected to have the column name of +id+ in the
    #                          primary table.
    #
    #    +original_columns+::  These are the columns listed in +column_names+.  They
    #                          will all exist in this history table with the same types
    #                          as they have in the primary table.
    #
    #    +effective_start+::   A datetime field which designates when this data was last
    #                          valid/active.  This is an inclusive value.
    #
    #    +effective_end+::     A datetime field which designates when this data was last
    #                          valid/active.  This is meant to be exclusive.
    #
    # And two unique indexes:
    #
    #    * uuid_end         The +effective_start+ datetime must be unique for a given group
    #                       of +uuid+s.
    #
    #    * id_uniq          The id of the column must be unique
    #
    def create_history_table_migration
      base_name = 'create_history_table_for'
      filename  = Utils.migration_file_name( base_name, table_name )
      config    = {
                    :migration_class      => Utils.migration_class_name( base_name ,table_name )
                  }

      template('templates/effective_date/create_effective_date_table.tt', filename, config)
    end

  end

  class Utils

    def self.root_migration_dir
      File.join( "db", "migrate" )
    end

    def self.function_base_name
      'ef_date_tr_func'
    end

    def self.migration_function_base_name
      "create_trigger_function_for"
    end

    def self.migration_trigger_base_name
      "add_trigger_to"
    end

    def self.migration_class_name( base_name, table_name )
      "#{base_name}_#{table_name}".split( '_' ).collect( &:capitalize ).join
    end

    # When these migrations get generated they may end up having the same timestamp.
    # This method ensures that each migration number is unique
    #
    def self.next_migration_number
      current = Dir.glob( File.join( root_migration_dir(), "[0-9]*_*.rb" ) ).inject( 0 ) do | max, file_path |
        n = File.basename( file_path ).split( '_', 2 ).first.to_i
        if n > max then n else max end
      end

      [ Time.now.strftime( '%Y%m%d%H%M%S' ), "%.14d" % ( current + 1 ) ].max
    end

    def self.migration_file_name( base_name, table_name )
      File.join(
        root_migration_dir(),
        "#{ next_migration_number() }_#{ base_name }_#{ table_name }.rb"
      )
    end
  end

  # Error raised when the table name so long that it may cause a
  # constraint name to be truncated.
  #
  class TableNameLengthExceeded < StandardError
    def message
      "The table name must not exceed #{ MAX_TABLE_NAME_LENGTH } characters in length"
    end
  end
end
