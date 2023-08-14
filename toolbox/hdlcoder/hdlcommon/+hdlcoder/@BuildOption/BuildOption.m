


classdef BuildOption



    enumeration
        Default,Custom
    end

    properties
    end

    methods
        function val=getBuildOptionByName(obj,name)
            switch(name)
            case 'Custom'
                val=hdlcoder.BuildOption.Custom;
            otherwise
                val=hdlcoder.BuildOption.Default;
            end
        end
    end

end

