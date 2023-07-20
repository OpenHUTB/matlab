classdef(Hidden=true)spreadSheetString<internal.parameterConfig.spreadSheetItem
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
            case obj.paramDialogColumn1
                propValue=obj.rowVariable;
            case obj.paramDialogColumn2

                if obj.isTopLevel
                    propValue=obj.dataSource.valueStructure(obj.rowPos2).exported;
                else
                    propValue=[];
                end
            case obj.paramDialogColumn3
                if isempty(obj.rowSource)
                    propValue='';
                elseif strcmp(obj.rowSource,'base workspace')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterBaseWorkspace');
                elseif strcmp(obj.rowSource,'model argument')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterModelArgument');
                elseif strcmp(obj.rowSource,'data dictionary')
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterDataDictionary');
                else
                    propValue=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterInstanceArgument');
                end
            case obj.paramDialogColumn4
                Idxs=obj.dataSource.valueScalarIndex{obj.rowPos1(1)};
                if numel(Idxs)==1
                    propValue=obj.dataSource.valueScalarTable(Idxs).description;
                else
                    propValue=obj.dataSource.valueScalarTable(Idxs(obj.rowPos1(2))).description;
                end
            case obj.paramDialogColumn6

                if obj.isTopLevel
                    propValue=obj.dataSource.valueStructure(obj.rowPos2).exportedName;
                else
                    propValue='';
                end
            otherwise
                warning('Unexpected type');
            end
        end


        function propType=getPropDataType(obj,propName)
            propType='string';
            if strcmp(propName,obj.paramDialogColumn2)
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
            if obj.isTopLevel&&strcmp(propName,obj.paramDialogColumn1)
                isHyperlink=true;
                param=obj.rowVariable;
                if clicked
                    if strcmp(obj.rowSource,'base workspace')
                        slprivate('exploreListNode','''','base',param);
                    elseif strcmp(obj.rowSource,'model argument')
                        mdl=obj.dataSource.mdlName;
                        slprivate('exploreListNode',mdl,'model',param);
                    else
                        src=obj.rowSource;
                        blkPath=src(9:end);
                        bps=strsplit(blkPath,':');
                        mdl=get_param(bps{end},'ModelName');
                        open_system(mdl);
                        slprivate('exploreListNode',mdl,'model',param);
                    end
                end
            end
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.paramDialogColumn1,obj.paramDialogColumn3,obj.paramDialogColumn4,obj.paramDialogColumn5}
                isReadOnly=true;
            case{obj.paramDialogColumn2,obj.paramDialogColumn6}
                isReadOnly=~obj.isTopLevel;
            otherwise
                warning('Unexpected type');
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case{obj.paramDialogColumn1,obj.paramDialogColumn3,obj.paramDialogColumn4}
                isValid=true;
            case{obj.paramDialogColumn2,obj.paramDialogColumn6}

                isValid=obj.isTopLevel;
            case obj.paramDialogColumn5
                isValid=false;
            otherwise
                warning('Unexpected type');
            end
        end
    end
end
