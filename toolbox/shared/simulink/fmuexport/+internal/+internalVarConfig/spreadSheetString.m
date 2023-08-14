classdef(Hidden=true)spreadSheetString<internal.internalVarConfig.spreadSheetItem




    properties
        rowVariable;
        rowSource;
        rowPos1;
        rowPos2;
    end
    methods

        function obj=spreadSheetString(dataSource,i,name,varSource,isTopLevel)
            obj.dataSource=dataSource;
            obj.isTopLevel=isTopLevel;
            obj.rowVariable=name;
            obj.rowSource=varSource;
            obj.rowPos1=obj.dataSource.workingIndex;
            obj.rowPos2=i;
        end


        function iconFile=getDisplayIcon(~)
            iconFile=fullfile('toolbox','shared','dastudio','resources','variable_fmi_str.png');
        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.ivDialogColumn1
                propValue=obj.rowVariable;
            case obj.ivDialogColumn2

                if obj.isTopLevel
                    propValue=obj.dataSource.valueStructure(obj.rowPos2).exported;
                else
                    propValue=[];
                end
            case obj.ivDialogColumn3
                if isempty(obj.rowSource)
                    propValue='';
                elseif strcmp(obj.rowSource,'Logged Signal')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVLoggedSignal');
                elseif strcmp(obj.rowSource,'Test Point')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVTestPoint');
                elseif strcmp(obj.rowSource,'Data Store')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDataStore');
                end
            case obj.ivDialogColumn4
                Idxs=obj.dataSource.valueScalarIndex{obj.rowPos1(1)};
                if numel(Idxs)==1
                    propValue=obj.dataSource.valueScalarTable(Idxs).description;
                else
                    propValue=obj.dataSource.valueScalarTable(Idxs(obj.rowPos1(2))).description;
                end
            case obj.ivDialogColumn6

                if obj.isTopLevel
                    propValue=obj.dataSource.valueStructure(obj.rowPos2).exportedName;
                else
                    propValue='';
                end
            case obj.ivDialogColumn7
                propValue=obj.dataSource.valueStructure(obj.rowPos2).dt;
            case obj.ivDialogColumn8
                propValue=obj.dataSource.valueStructure(obj.rowPos2).exportedDT;
            otherwise
                warning('Unexpected type');
            end
        end


        function propType=getPropDataType(obj,propName)
            propType='string';
            if strcmp(propName,obj.ivDialogColumn2)
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


        function isHyperlink=propertyHyperlink(obj,propName,clicked)
            isHyperlink=false;
            if obj.isTopLevel&&strcmp(propName,obj.ivDialogColumn1)
                isHyperlink=true;
                if clicked
                    obj.hiliteFcn();
                end
            end
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.ivDialogColumn1,obj.ivDialogColumn3,obj.ivDialogColumn4,obj.ivDialogColumn5,obj.ivDialogColumn7,obj.ivDialogColumn8}
                isReadOnly=true;
            case{obj.ivDialogColumn2,obj.ivDialogColumn6}
                isReadOnly=~obj.isTopLevel;
            otherwise
                warning('Unexpected type');
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case{obj.ivDialogColumn1,obj.ivDialogColumn3,obj.ivDialogColumn4,obj.ivDialogColumn7}
                isValid=true;
            case{obj.ivDialogColumn2,obj.ivDialogColumn6,obj.ivDialogColumn8}

                isValid=obj.isTopLevel;
            case obj.ivDialogColumn5
                isValid=false;
            otherwise
                warning('Unexpected type');
            end
        end
    end
end
