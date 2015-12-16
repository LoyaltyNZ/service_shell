#!/usr/bin/env ruby

########################################################################
# File::    effective_date.rb
# (C)::     Loyalty New Zealand 2015
#
# Purpose:: Front-end to "classes/effective_date_class.rb". This is a
#           Thor command-line tool. See "effective_date_class.rb" for
#           extensive documentation.
# ----------------------------------------------------------------------
#           28-Jul-2015 (DAM): Created.
#           13-Nov-2015 (ADH): Split into "effective_date_class.rb".
########################################################################

$LOAD_PATH.unshift( File.dirname( __FILE__ ) )

require 'classes/effective_date_class.rb'

Generators::EffectiveDate.start
