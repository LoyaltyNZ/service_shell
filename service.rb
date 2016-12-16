# Top level service class that describes the component interfaces. This is
# run by config.ru. The class must be called "ServiceApplication" (unless
# "config.ru" has been modified).

class ServiceApplication < Hoodoo::Services::Service
  raise "Write one or more classes in service/implementations and service/interfaces, then refer to the interfaces here via 'comprised_of'"
  # comprised_of SomeInterface [, SomeOtherInterface, AThirdInterface, ...]
end
