classdef DesktopBlockParameterHelper<Simulink.Simulation.internal.BlockParameterHelper
    methods(Static)
        function validateSettableParam(blockPath,name)




            C=strsplit(blockPath,'/');
            if numel(C)<=1
                DAStudio.error('Simulink:Commands:SimInputInvalidBlockPath',blockPath);
            end
            modelName=C{1};
            if bdIsLoaded(modelName)




                Simulink.Simulation.internal.DesktopBlockParameterHelper.checkReadOnlyParameter(blockPath,name);
            end
        end

        function validateParam(blockPath,name)



            splitStrs=strsplit(blockPath,'/');
            modelName=splitStrs{1};
            if~bdIsLoaded(modelName)
                load_system(modelName);
            end


            try
                get_param(blockPath,name);
            catch ME

                if strcmp(ME.identifier,'Simulink:Commands:ParamUnknown')
                    throwAsCaller(ME)
                end
            end


            Simulink.Simulation.internal.DesktopBlockParameterHelper.checkReadOnlyParameter(blockPath,name);
        end
    end

    methods(Static,Access=private)
        function checkReadOnlyParameter(blockPath,name)
            params=get_param(blockPath,'ObjectParameters');
            paramNames=fieldnames(params);
            idx=find(strcmpi(paramNames,name),1);
            if~isempty(idx)
                attrs=params.(paramNames{idx}).Attributes;
                if any(strcmp(attrs,'read-only'))
                    error(message('Simulink:Commands:SimInputReadOnlyBlockParam',name));
                end
            end
        end
    end
end