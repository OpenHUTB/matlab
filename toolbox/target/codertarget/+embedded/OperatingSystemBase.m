classdef(Sealed=false)OperatingSystemBase<matlab.mixin.SetGet


















    properties(Access='public')







        Name='';
    end
    properties(Access='public',Hidden)
        ConfigurationFile='';
    end
    properties(Access='public',Hidden,Constant)
        LISTOFFACTORYOS={'Linux','VxWorks'};
    end
    methods(Access='public')
        function h=OperatingSystemBase(operatingSystemName)
            operatingSystemName=convertStringsToChars(operatingSystemName);
            h.Name=operatingSystemName;
        end
        function register(h,directory)

        end
        function deserialize(h,schedulerfile)







        end
    end
    methods(Access='private')
        function serialize(h,directory)








        end
    end
end
