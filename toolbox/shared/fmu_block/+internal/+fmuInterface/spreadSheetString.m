classdef(Hidden=true)spreadSheetString<internal.fmuInterface.spreadSheetItem
    properties
        rowVariable;
        rowPos1;
        rowPos2;
    end
    methods

        function obj=spreadSheetString(dataSource,i,name,isTopLevel)
            obj.dlgSource=dataSource.dlgSource;
            obj.dataSource=dataSource;
            obj.isTopLevel=isTopLevel;
            obj.rowVariable=name;
            obj.rowPos1=obj.dataSource.workingIndex;
            obj.rowPos2=i;
        end


        function iconFile=getDisplayIcon(~)
            iconFile=fullfile('toolbox','shared','dastudio','resources','variable_fmi_str.png');
        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.FMUDialogColumn1
                propValue=obj.rowVariable;
            case obj.FMUDialogColumn2
                if obj.isTopLevel
                    if obj.rowPos2==0
                        propValue=[];
                    else
                        propValue=obj.dataSource.valueStructure(obj.rowPos2).IsVisible;
                    end
                else
                    if obj.rowPos2==0
                        propValue=obj.dataSource.internalValueStructure(obj.rowPos1(1)).IsVisible;
                    else
                        propValue=[];
                    end
                end
            case obj.FMUDialogColumn3
                if obj.rowPos2==0
                    Idxs=obj.dataSource.internalValueScalarIndex{obj.rowPos1(1)};
                else
                    Idxs=obj.dataSource.valueScalarIndex{obj.rowPos1(1)};
                end
                if numel(Idxs)==1
                    varName=obj.dataSource.valueScalarTable(Idxs).name;
                else
                    varName=obj.dataSource.valueScalarTable(Idxs(obj.rowPos1(2))).name;
                end
                if obj.dlgSource.DialogData.InputAlteredNameStartMap.isKey(varName)
                    propValue=obj.dlgSource.DialogData.InputAlteredNameStartMap(varName);
                else
                    if numel(Idxs)==1
                        propValue=obj.dataSource.valueScalarTable(Idxs).start;
                    else
                        propValue=obj.dataSource.valueScalarTable(Idxs(obj.rowPos1(2))).start;
                    end
                end
            case obj.FMUDialogColumn4
                propValue='';
            case obj.FMUDialogColumn5
                propValue=[];
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
            if obj.isTopLevel

                obj.updateValueTable(propName,propValue,obj.rowPos1,obj.rowPos2);
            else

                assert(false,'string cannot be a member of struct or array variable.');
            end
        end


        function getMetaInfo(obj,info)
            info.FilterKey='';
            Idxs=obj.dataSource.valueScalarIndex{obj.rowPos1(1)};
            if numel(Idxs)==1
                info.FilterKey=obj.dataSource.valueScalarTable(Idxs).name;
            else
                info.FilterKey=obj.dataSource.valueScalarTable(Idxs(obj.rowPos1(2))).name;
            end
        end

        function isHier=isHierarchical(~)
            isHier=false;
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.FMUDialogColumn1,obj.FMUDialogColumn4,obj.FMUDialogColumn5}
                isReadOnly=true;
            case obj.FMUDialogColumn2
                if obj.rowPos2==0
                    isReadOnly=obj.isTopLevel||obj.dataSource.isLinkToLibrary;
                else
                    isReadOnly=~obj.isTopLevel||obj.dataSource.isLinkToLibrary;
                end
            case obj.FMUDialogColumn3

                if obj.rowPos2==0
                    isVisible=obj.dataSource.internalValueStructure(obj.rowPos1(1)).IsVisible;
                else
                    isVisible=obj.dataSource.valueStructure(obj.rowPos2).IsVisible;
                end
                if obj.dataSource.isInputTab&&strcmp(isVisible,'off')
                    isReadOnly=false;
                else
                    isReadOnly=true;
                end
            otherwise
                warning('Unexpected type');
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case{obj.FMUDialogColumn1,obj.FMUDialogColumn3}
                isValid=true;
            case obj.FMUDialogColumn2
                if obj.rowPos2==0
                    isValid=~obj.isTopLevel;
                else

                    isValid=obj.isTopLevel;
                end
            case{obj.FMUDialogColumn4,obj.FMUDialogColumn5}
                isValid=false;
            otherwise
                warning('Unexpected type');
            end
        end
    end
end
