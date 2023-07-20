classdef(Hidden=true)spreadSheetStruct<internal.fmuInterface.spreadSheetItem
    properties
        rowVariable;
        rowBusObjectName;
        rowPos1;
        rowPos2;

        children;
    end
    methods

        function obj=spreadSheetStruct(dataSource,i,name,busObjectName,children,isTopLevel)
            obj.dlgSource=dataSource.dlgSource;
            obj.dataSource=dataSource;
            obj.isTopLevel=isTopLevel;
            obj.rowVariable=name;
            obj.rowBusObjectName=busObjectName;
            if obj.isTopLevel
                obj.rowPos1=obj.dataSource.workingIndex(1);
            else
                obj.rowPos1=[];
            end
            obj.rowPos2=i;
            obj.children=children;
        end


        function iconFile=getDisplayIcon(~)
            iconFile=fullfile('toolbox','shared','dastudio','resources','variable_fmi_struct.png');
        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.FMUDialogColumn1
                propValue=obj.rowVariable;
            case obj.FMUDialogColumn2
                if obj.isTopLevel
                    if obj.mIisInternal
                        propValue=obj.dataSource.internalValueStructure(obj.rowPos2).IsVisible;
                    else
                        propValue=obj.dataSource.valueStructure(obj.rowPos2).IsVisible;
                    end
                else
                    propValue=[];
                end
            case obj.FMUDialogColumn3
                propValue=[];
            case obj.FMUDialogColumn4
                propValue='';
            case obj.FMUDialogColumn5
                if obj.isTopLevel&&~isempty(obj.rowBusObjectName)
                    if obj.mIisInternal
                        propValue=obj.dataSource.internalValueStructure(obj.rowPos2).BusObjectName;
                    else
                        propValue=obj.dataSource.valueStructure(obj.rowPos2).BusObjectName;
                    end
                else
                    propValue=[];
                end
            otherwise
                warning('Unexpected type');
            end
        end


        function propType=getPropDataType(obj,propName)
            propType='string';
            if strcmp(propName,obj.FMUDialogColumn2)
                propType='bool';
            end
        end



        function setPropValue(obj,propName,propValue)

            assert(obj.isTopLevel);
            obj.updateValueTable(propName,propValue,obj.rowPos1,obj.rowPos2);
        end


        function isHier=isHierarchical(~)
            isHier=true;
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.FMUDialogColumn1,obj.FMUDialogColumn4}
                isReadOnly=true;
            case obj.FMUDialogColumn2
                isReadOnly=~obj.isTopLevel||obj.dataSource.isLinkToLibrary;
            case{obj.FMUDialogColumn3,obj.FMUDialogColumn5}
                isReadOnly=false;
            otherwise
                warning('Unexpected type');
            end
        end


        function children=getHierarchicalChildren(obj)
            children=obj.children;
        end


        function isValid=isValidProperty(obj,propName)
            if strcmp(obj.rowVariable,DAStudio.message('FMUBlock:FMU:InternalVariables'))
                isValid=false;
            else
                switch propName
                case obj.FMUDialogColumn1
                    isValid=true;
                case obj.FMUDialogColumn2

                    isValid=obj.isTopLevel;
                case{obj.FMUDialogColumn3,obj.FMUDialogColumn4}

                    isValid=false;
                case obj.FMUDialogColumn5
                    isValid=obj.isTopLevel&&~isempty(obj.rowBusObjectName);
                otherwise
                    warning('Unexpected type');
                end
            end
        end
    end
end
