classdef TaskEditorRowItem<handle





    properties
ColumnNames
Block
BlockPath
Task
PipelineStage
SourceObj
RegionId
        ClassPropertyNames={'Block','PipelineStage','Task'};
    end

    methods

        function obj=TaskEditorRowItem(srcObj,regionId,blockPath,pipelineStage,task)
            obj.BlockPath=blockPath;
            relativePath=split(blockPath,'/');
            if length(relativePath)>1

                relativePath(1)=[];
            end
            obj.Block=strjoin(relativePath,'/');
            obj.Task=task;
            obj.PipelineStage=pipelineStage;
            obj.SourceObj=srcObj;
            obj.ColumnNames=getColumns(srcObj);
            obj.RegionId=regionId;
        end

        function propValue=getPropValue(obj,propName)
            classPropName=getClassPropName(obj,propName);
            propValue=obj.(classPropName);
        end

        function setPropValue(obj,propName,newVal)
            classPropName=getClassPropName(obj,propName);
            obj.(classPropName)=newVal;
        end

        function isHyperlink=propertyHyperlink(obj,propName,clicked)
            classPropName=getClassPropName(obj,propName);
            isHyperlink=false;

            if strcmp(classPropName,'Block')&&...
                ~isempty(obj.BlockPath)&&...
                getSimulinkBlockHandle(obj.BlockPath)~=-1
                isHyperlink=true;
                if clicked
                    removeAllHighlighting(obj.SourceObj.UIObj);
                    modelName=getModelName(obj.SourceObj.MappingData,obj.RegionId);
                    set_param(modelName,'HiliteAncestors','off');

                    modelPath=getModelPath(obj.SourceObj.MappingData,obj.RegionId);
                    bp=Simulink.BlockPath([modelPath,{obj.BlockPath}]);
                    hilite_system(bp);
                    set_param(obj.BlockPath,'Selected','on');

                end
            end
        end

        function aPropType=getPropDataType(~,~)
            aPropType='string';
        end

        function isValid=isValidProperty(obj,propName)
            isValid=~isempty(find(strcmp(obj.ColumnNames,propName),1));
        end

        function tf=isDragAllowed(~)
            tf=true;
        end

        function isReadOnly=isReadonlyProperty(~,~)
            isReadOnly=true;
        end

        function isEditable=isEditableProperty(~,~)
            isEditable=false;
        end


        function isHier=isHierarchical(~)
            isHier=true;
        end

        function classPropName=getClassPropName(obj,propName)
            idx=find(strcmp(getColumns(obj.SourceObj),propName),1);
            classPropName=obj.ClassPropertyNames{idx};
        end
    end
end


