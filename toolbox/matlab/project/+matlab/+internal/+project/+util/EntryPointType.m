classdef EntryPointType




    enumeration

StartUp

Shutdown

CustomTask

Basic
    end

    methods(Access=public,Static)
        function entryPointType=convertFromJava(javaEnum)
            matlabString=char(javaEnum.getName());

            if strcmp(matlabString,'Batch Job')
                matlabString='CustomTask';
            end

            entryPointType=matlab.internal.project.util.EntryPointType.(matlabString);
        end
    end

end