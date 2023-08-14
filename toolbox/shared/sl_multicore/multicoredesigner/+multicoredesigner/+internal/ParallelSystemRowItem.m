classdef ParallelSystemRowItem<handle





    properties
ColumnName
DisplayName
ChildObjs
SourceObj
RegionId
    end

    methods


        function obj=ParallelSystemRowItem(srcObj,regionId,columnName,name,childObjs)
            obj.ColumnName=columnName;
            obj.DisplayName=name;
            obj.SourceObj=srcObj;
            obj.RegionId=regionId;
            obj.ChildObjs=childObjs;
        end

        function propValue=getPropValue(obj,propName)
            propValue='';
            if strcmp(propName,obj.ColumnName)
                propValue=obj.DisplayName;
            end
        end

        function setPropValue(obj,propName,newVal)
            if strcmp(propName,obj.ColumnName)
                obj.(propName)=newVal;
            end
        end

        function isHyperlink=propertyHyperlink(obj,propName,clicked)
            if strcmp(propName,obj.ColumnName)&&...
                ~isempty(obj.DisplayName)&&...
                getSimulinkBlockHandle(obj.DisplayName)~=-1&&...
                strcmpi(get_param(obj.DisplayName,'BlockType'),'SubSystem')
                isHyperlink=true;
                if clicked
                    modelPath=getModelPath(obj.SourceObj.MappingData,obj.RegionId);
                    bp=Simulink.BlockPath([modelPath,{obj.DisplayName}]);
                    bp.open();
                end
            else
                isHyperlink=false;
            end
        end

        function isValid=isValidProperty(obj,propName)
            isValid=strcmp(propName,obj.ColumnName);
        end

        function getPropertyStyle(obj,~,propertyStyle)
            if~isempty(obj.ChildObjs)
                propertyStyle.BackgroundColor=[1,1,0.9];
            end
        end

        function tf=isDragAllowed(~)
            tf=false;
        end

        function isRead=isReadonlyProperty(~,~)
            isRead=true;
        end

        function res=isEditableProperty(~,~)
            res=false;
        end


        function isHier=isHierarchical(~)
            isHier=true;
        end

        function children=getHierarchicalChildren(obj)
            children=obj.ChildObjs;
        end

    end
end
