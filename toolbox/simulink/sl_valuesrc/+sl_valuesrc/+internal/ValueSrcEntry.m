classdef ValueSrcEntry<sl_valuesrc.internal.ValueEntry





    properties(Access=private)
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ValueSrcEntry(srcObj,defObj,controllerObj,parentObj)
            thisObj@sl_valuesrc.internal.ValueEntry(srcObj,defObj,controllerObj,parentObj);
        end

        function hasActions=hasPropertyActions(thisObj,propName)
            hasActions=isequal(propName,'Value');
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            if isequal(propName,'Value')
                readonly=true;
            else
                readonly=true;
            end
        end

        function propVal=getPropValue(thisObj,propName)
            switch propName
            case 'Value'
                try
                    propVal=thisObj.mSrcObj.getValueThroughOverlayThrowError(thisObj.mParentObj);
                    if~isempty(propVal)
                        propVal=DAStudio.MxStringConversion.convertToString(propVal);
                    else
                        propVal='–';
                    end
                catch ME
                    propVal='?';
                end
            case 'Source'
                propVal=thisObj.mSrcObj.getSource();
                [~,name,ext]=fileparts(propVal);
                propVal=[name,ext];
            otherwise
                if thisObj.isValidProperty(propName)
                    propVal=getPropValue@sl_valuesrc.internal.ValueEntry(thisObj,propName);
                else
                    propVal=thisObj.getMxPropValue(propName);
                end
            end
        end

        function setPropValue(thisObj,propName,value)
            if isequal(propName,'Value')
                thisObj.mSrcObj.setValue(value);
            end
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct=da_mxarray_get_schema(thisObj);
            valueLabel=DAStudio.message('dastudio:ddg:WSOValue');
            for i=1:numel(dlgStruct.Items)
                if isfield(dlgStruct.Items{i},'ObjectProperty')&&...
                    isequal(dlgStruct.Items{i}.ObjectProperty,'Value')
                    dlgStruct.Items{i}.Source=thisObj;
                    dlgStruct.Items{i}.Visible=true;
                end
                if isfield(dlgStruct.Items{i},'Tag')
                    tag=dlgStruct.Items{i}.Tag;
                    if~isequal(tag,'matrixcontainer_tag')&&~isequal(tag,'value_tag')
                        dlgStruct.Items{i}.Visible=false;
                    end
                elseif isfield(dlgStruct.Items{i},'Name')&&isequal(dlgStruct.Items{i}.Name,valueLabel)
                    continue;
                else

                    dlgStruct.Items{i}.Visible=false;
                end
            end


            objGrp.Name='';
            objGrp.Type='panel';
            objGrp.Items=dlgStruct.Items;
            if isfield(dlgStruct,'LayoutGrid')
                objGrp.LayoutGrid=dlgStruct.LayoutGrid;
            end
            if isfield(dlgStruct,'RowStretch')
                objGrp.RowStretch=dlgStruct.RowStretch;
            end
            if isfield(dlgStruct,'ColStretch')
                objGrp.ColStretch=dlgStruct.ColStretch;
            end
            objGrp.RowSpan=[1,1];
            objGrp.ColSpan=[1,2];

            nameLbl.Name=message('sl_valuesrc:messages:NameLabel').getString;
            nameLbl.Type='text';
            nameLbl.RowSpan=[1,1];
            nameLbl.ColSpan=[1,1];
            nameFld.Name=thisObj.mParentObj.getName();
            nameFld.Tag='name';
            nameFld.Type='text';
            nameFld.RowSpan=[1,1];
            nameFld.ColSpan=[2,2];

            overlayFile=thisObj.mParentObj.getSource();
            [path,name,ext]=fileparts(overlayFile);
            filedisp=[name,ext];

            fileLbl.Name=message('sl_valuesrc:messages:FileLabel').getString;
            fileLbl.Type='text';
            fileLbl.RowSpan=[2,2];
            fileLbl.ColSpan=[1,1];
            fileFld.Name=filedisp;
            fileFld.Tag='file';
            fileFld.Type='text';
            fileFld.RowSpan=[2,2];
            fileFld.ColSpan=[2,2];

            metaGrp.Name=message('sl_valuesrc:messages:OverlayLabel').getString;
            metaGrp.Type='group';
            metaGrp.LayoutGrid=[2,2];
            metaGrp.ColStretch=[0,1];
            metaGrp.RowSpan=[2,2];
            metaGrp.ColSpan=[1,2];
            metaGrp.Items={nameLbl,nameFld,fileLbl,fileFld};

            dlgStruct.Items={objGrp,metaGrp};
            dlgStruct.LayoutGrid=[2,2];
            dlgStruct.ColStretch=[0,0];
            dlgStruct.RowStretch=[1,0];
        end

    end


    methods(Access=private)
        function propValue=getMxPropValue(thisObj,propName)
            value=thisObj.mSrcObj.getValue();
            switch propName
            case 'DataType'
                propValue=class(value);
            case 'Value'
                propValue=DAStudio.MxStringConversion.convertToString(value);
            case '_Value'
                propValue=value;
            case 'Dimensions'
                tempVal=size(value);
                propValue=strcat('[',strcat(num2str(tempVal),']'));
            case 'Complexity'
                if(isnumeric(value))
                    if(isreal(value))
                        propValue='real';
                    else
                        propValue='complex';
                    end
                else
                    propValue='N/A';
                end
            otherwise
                propValue='';
            end
        end
    end

end