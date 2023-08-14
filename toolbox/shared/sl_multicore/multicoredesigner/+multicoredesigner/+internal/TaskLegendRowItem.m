classdef TaskLegendRowItem<handle





    properties
SystemId
TaskId
TaskType
TaskName
HighlightEnabled
Color
Source
Enabled
        ClassPropertyNames={'HighlightEnabled','TaskName','Color'};
    end

    methods

        function obj=TaskLegendRowItem(source,systemId,relativeTaskId,taskType,taskName,enabled)
            obj.SystemId=systemId;
            obj.TaskId=relativeTaskId;
            obj.TaskType=taskType;
            obj.TaskName=taskName;
            obj.Source=source;
            highlighter=getTaskHighlighter(source.UIObj);

            if strcmp(taskType,'Multiple')
                obj.HighlightEnabled='';
            else
                if isTaskHighlighted(highlighter,systemId,relativeTaskId)
                    obj.HighlightEnabled='1';
                else
                    obj.HighlightEnabled='0';
                end
            end
            if enabled
                obj.Color=getColorForTask(highlighter,systemId,relativeTaskId,taskType);
            else
                obj.Color=[0.7,0.7,0.7];
            end
            obj.Enabled=enabled;
        end


        function propValue=getPropValue(obj,propName)
            classPropName=getClassPropName(obj,propName);
            propValue=obj.(classPropName);
        end

        function setPropValue(obj,propName,newVal)
            classPropName=getClassPropName(obj,propName);
            if strcmp(classPropName,'HighlightEnabled')&&...
                ~strcmp(obj.HighlightEnabled,newVal)
                obj.HighlightEnabled=newVal;
                highlighter=getTaskHighlighter(obj.Source.UIObj);
                if strcmp(newVal,'1')
                    removeCriticalPathHighlighting(obj.Source.UIObj);
                    highlightTask(highlighter,obj.SystemId,obj.TaskId,obj.TaskType);
                else
                    removeTaskHighlight(highlighter,obj.SystemId,obj.TaskId);
                end
            end
        end

        function getPropertyStyle(obj,propName,propertyStyle)
            classPropName=getClassPropName(obj,propName);
            if(isequal(classPropName,'Color'))&&obj.Enabled
                barWidth=20;
                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',1,'Colors',[obj.Color,1],'Width',barWidth+20);
            end

            if~obj.Enabled
                propertyStyle.ForegroundColor=[0.7,0.7,0.7];
            end
        end

        function aPropType=getPropDataType(obj,propName)
            classPropName=getClassPropName(obj,propName);
            if strcmp(classPropName,'HighlightEnabled')
                aPropType='bool';
            else
                aPropType='string';
            end
        end

        function isHyperlink=propertyHyperlink(~,~,~)
            isHyperlink=false;
        end

        function isValid=isValidProperty(obj,propName)
            isValid=~isempty(find(strcmp(getColumns(obj.Source),propName),1));
        end

        function tf=isDragAllowed(~)
            tf=false;
        end

        function isRead=isReadonlyProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);

            if obj.Enabled&&strcmp(classPropName,'HighlightEnabled')&&...
                ~strcmp(obj.TaskType,'Multiple')
                isRead=false;
            else
                isRead=true;
            end
        end

        function isEditable=isEditableProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);
            if obj.Enabled&&strcmp(classPropName,'HighlightEnabled')&&...
                ~strcmp(obj.TaskType,'Multiple')
                isEditable=true;
            else
                isEditable=false;
            end
        end


        function isHier=isHierarchical(~)
            isHier=false;
        end

        function classPropName=getClassPropName(obj,propName)
            idx=find(strcmp(getColumns(obj.Source),propName),1);
            classPropName=obj.ClassPropertyNames{idx};
        end
    end
end


