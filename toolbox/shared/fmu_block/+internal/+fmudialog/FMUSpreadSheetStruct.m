classdef(Hidden=true)FMUSpreadSheetStruct<internal.fmudialog.FMUSpreadSheetItem
    properties
        rowParameter;
        rowValueStringPos;

        children;
    end
    methods

        function obj=FMUSpreadSheetStruct(dataSource,name,children,isTopLevel)
            obj.dlgSource=dataSource.dlgSource;
            obj.dataSource=dataSource;
            obj.isTopLevel=isTopLevel;
            obj.rowParameter=name;
            if obj.dataSource.showAsStruct&&obj.isTopLevel
                obj.rowValueStringPos=obj.dataSource.workingIndex(1);
            else
                obj.rowValueStringPos=[];
            end
            obj.children=children;
        end


        function iconFile=getDisplayIcon(obj)
            iconFile=fullfile('toolbox','shared','dastudio','resources','variable_fmi_struct.png');
        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.FMUDialogColumn1
                propValue=obj.rowParameter;
            case obj.FMUDialogColumn2
                if~isempty(obj.rowValueStringPos)
                    propValue=obj.dataSource.valueString{obj.rowValueStringPos(1)};
                else
                    propValue=[];
                end
            case{obj.FMUDialogColumn3,obj.FMUDialogColumn4}
                propValue='';
            otherwise
                warning('Unexpected type');
            end
        end


        function propType=getPropDataType(obj,propName)
            propType='string';
        end



        function setPropValue(obj,propName,propValue)


            assert(obj.isTopLevel);
            obj.updateValueString(propValue,obj.rowValueStringPos);
        end


        function isHier=isHierarchical(obj)
            isHier=true;
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case obj.FMUDialogColumn2
                isReadOnly=isempty(obj.rowValueStringPos)||...
                ~obj.dlgSource.DialogData.ListEnabled(obj.rowValueStringPos(1))||...
                obj.dlgSource.DialogData.ListReadOnly(obj.rowValueStringPos(1));
            case{obj.FMUDialogColumn1,obj.FMUDialogColumn3,obj.FMUDialogColumn4}
                isReadOnly=true;
            otherwise
                warning('Unexpected type');
            end
        end


        function children=getHierarchicalChildren(obj)
            children=obj.children;
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case obj.FMUDialogColumn1
                isValid=true;
            case obj.FMUDialogColumn2
                isValid=~isempty(obj.rowValueStringPos);
            case{obj.FMUDialogColumn3,obj.FMUDialogColumn4}


                isValid=false;
            otherwise
                warning('Unexpected type');
            end
        end
    end
end
