classdef Workspace





    methods(Static,Access=public)
        function[varExists,object,isModelWorkspace]=objectExistsInModelScope(modelName,objectName)




            if iscell(objectName)
                [varExists,object,isModelWorkspace]=...
                cellfun(@(x)autosar.utils.Workspace.objectExistsInModelScope(modelName,x),objectName,'UniformOutput',false);
                return;
            end

            modelWorkSpace=get_param(modelName,'ModelWorkspace');

            varExists=false;
            object=[];
            isModelWorkspace=false;

            if~isvarname(objectName)

                return;
            end


            if~isempty(modelWorkSpace)
                varExistsInModelWS=modelWorkSpace.hasVariable(objectName)==1;
                if varExistsInModelWS
                    object=modelWorkSpace.getVariable(objectName);
                    isModelWorkspace=true;
                    varExists=true;
                    return;
                end
            end

            if existsInGlobalScope(modelName,objectName)
                if~Simulink.data.isSupportedEnumClass(objectName)

                    simInputGlobalWksp=get_param(modelName,"SimulationInputGlobalWorkspace");





                    if~isempty(simInputGlobalWksp)&&simInputGlobalWksp.hasVariable(objectName)==1
                        object=simInputGlobalWksp.getVariable(objectName);
                    else
                        object=evalinGlobalScope(modelName,objectName);
                    end
                    varExists=true;
                    return;
                end
            end
        end
    end
end


