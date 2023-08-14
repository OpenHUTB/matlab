classdef TaskClass

    enumeration
        Standard,Safety
    end

    methods(Static)
        function ret=getClass(class_name)
            import plccore.common.TaskClass;
            if strcmp(class_name,'Safety')
                ret=TaskClass.Safety;
            else
                ret=TaskClass.Standard;
            end
        end

        function ret=taskClassName(clas)
            import plccore.common.TaskClass;
            switch clas
            case TaskClass.Standard
                ret='Standard';
            case TaskClass.Safety
                ret='Safety';
            otherwise
                assert(false);
            end
        end
    end
end