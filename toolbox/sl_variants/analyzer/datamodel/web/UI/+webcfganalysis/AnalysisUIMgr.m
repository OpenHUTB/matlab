classdef AnalysisUIMgr<handle






    properties(Access=private)
        openInstances;
    end

    methods(Access=private)

        function obj=AnalysisUIMgr()
            obj.openInstances=i_newEmptyInstanceStruct();
        end


        function mdlIndex=findModelInstance(obj,modelName)
            mdlIndex=arrayfun(@(x)strcmp(x.ModelName,modelName),...
            obj.openInstances);
        end
    end

    methods(Access=public)
        function addModelInstance(obj,modelName,analysisUI)

            if~any(obj.findModelInstance(modelName))
                obj.openInstances(end+1)=struct('ModelName',modelName,...
                'AnalysisObj',analysisUI);
            end
        end

        function webWindow=getWebWindowForModel(obj,modelName)
            webWindow=[];
            mdlIndex=obj.findModelInstance(modelName);
            if any(mdlIndex)
                webWindow=obj.openInstances(mdlIndex).AnalysisObj.webWindow;
            end
        end

        function removeModelInstance(obj,modelName)
            mdlIndex=obj.findModelInstance(modelName);
            if any(mdlIndex)
                obj.openInstances(mdlIndex)=[];
            end
        end

        function analysisUI=getAnalysisUI(obj,modelName)
            analysisUI=[];
            mdlIndex=obj.findModelInstance(modelName);
            if any(mdlIndex)
                analysisUI=obj.openInstances(mdlIndex).AnalysisObj;
            end
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent uniqueInstance;
            if(isempty(uniqueInstance))
                obj=webcfganalysis.AnalysisUIMgr();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end
end



function instances=i_newEmptyInstanceStruct()
    instances=struct('ModelName','',...
    'AnalysisObj',[]);
    instances(end)=[];
end
