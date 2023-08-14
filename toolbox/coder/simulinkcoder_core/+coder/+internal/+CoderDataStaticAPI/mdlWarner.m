classdef mdlWarner





    properties
mdlH
    end
    methods
        function obj=mdlWarner(hdl)
            obj.mdlH=hdl;
        end
        function warnIfMdl(obj)
            if strcmp(get_param(obj.mdlH,'IsHarness'),'on')
                return;
            end

            saveOptions=Simulink.internal.BDSaveOptions(obj.mdlH);
            if isempty(saveOptions)||~saveOptions.hasSaveOptions
                return;
            end

        end
    end
end


