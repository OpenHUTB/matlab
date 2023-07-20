classdef ItemState<Simulink.IntEnumType



    enumeration
        Normal(1)
        Error(2)
        Warning(3)
    end
    methods(Static)
        function retVal=getDefaultValue()
            retVal=starepository.ioitemproperty.ItemState.Normal;
        end
    end
end