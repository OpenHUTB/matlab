classdef SuggestionsRowItem<handle





    properties
SourceObj
Region
System
CurrentLatency
SuggestedLatency
Accept
        ClassPropertyNames={'Region','CurrentLatency','SuggestedLatency','Accept'};
    end

    methods
        function obj=SuggestionsRowItem(src,regionId,latency,suggestion)
            obj.SourceObj=src;
            obj.Region=getRegionName(src.UIObj.MappingData,regionId);
            obj.System=getParentSystemName(src.UIObj.MappingData,regionId);
            obj.CurrentLatency=latency;
            obj.SuggestedLatency=suggestion;
            obj.Accept='0';
        end

        function propValue=getPropValue(obj,propName)
            classPropName=getClassPropName(obj,propName);
            propValue=obj.(classPropName);
        end

        function setPropValue(obj,propName,newVal)
            classPropName=getClassPropName(obj,propName);
            obj.(classPropName)=newVal;
            if strcmp(classPropName,'Accept')
                if strcmp(newVal,'1')
                    set_param(obj.System,'Latency',obj.SuggestedLatency);
                else
                    set_param(obj.System,'Latency',obj.CurrentLatency);
                end
            end
        end

        function aPropType=getPropDataType(obj,propName)
            aPropType='string';
            classPropName=getClassPropName(obj,propName);
            if strcmp(classPropName,'Accept')
                aPropType='bool';
            end
        end

        function isHyperlink=propertyHyperlink(~,~,~)
            isHyperlink=false;
        end

        function isValid=isValidProperty(obj,propName)
            isValid=false;
            classPropName=getClassPropName(obj,propName);
            try
                obj.(classPropName);
                isValid=true;
            catch
            end
        end

        function tf=isDragAllowed(~)
            tf=true;
        end
        function isRead=isReadonlyProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);
            if strcmp(classPropName,'Accept')
                isRead=false;
            else
                isRead=true;
            end
        end

        function isEditable=isEditableProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);
            if strcmp(classPropName,'Accept')
                isEditable=true;
            else
                isEditable=false;
            end
        end

        function classPropName=getClassPropName(obj,propName)
            idx=find(strcmp(getColumns(obj.SourceObj),propName),1);
            classPropName=obj.ClassPropertyNames{idx};
        end
    end
end
