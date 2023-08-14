function rowData=lookuptableddg_addData(hProxy,tableData,rowIdx,isBpFromALUTObj,supportEnumType,varargin)





    if isa(hProxy,'Simulink.SlidDAProxy')
        hSlidObject=hProxy.getObject();
        h=hSlidObject.WorkspaceObjectSharedCopy;
    else
        h=hProxy;
    end

    if(nargin>=6)
        wsObj=varargin{1};
    else
        wsObj=[];
    end
    if slfeature('EnableStoredIntMinMax')>=2
        ignoreStoredIntColumn=false;
        if(nargin==7)
            ignoreStoredIntColumn=varargin{2};
        end
    end

    cols=getColumnForGivenTable(h,isBpFromALUTObj,tableData,wsObj,ignoreStoredIntColumn);

    rowData=getBreakpointOrTableRow(hProxy,h,isBpFromALUTObj,tableData,wsObj,cols,rowIdx,supportEnumType);

end

function rowData=getBreakpointOrTableRow(hProxy,h,isBpFromALUTObj,tableData,wsObj,cols,rowIdx,supportEnumType)

    colcount=length(cols);

    rowData={};

    if(isBpFromALUTObj&&isequal(h.DialogData.BreakpointsSpecification,'Reference'))
        rowData=getRowDataForReferenceBreakpoint(tableData,cols);
    else
        for colidx=1:colcount
            colData=[];
            colData.Name=cols{colidx};
            if isequal(colData.Name,'DataType')
                colData=getRowDataForDataTypeField(hProxy,tableData,colData,supportEnumType);
            else
                colData.Type='edit';
            end
            colData.Alignment=6;

            if isReadonlyProperty(tableData,colData.Name)
                colData.Enabled=false;
            else
                colData.Enabled=true;
            end

            if isequal(colData.Name,'Value')
                colData=getRowDataForValueField(h,tableData,colData,isBpFromALUTObj,rowIdx);
            elseif isequal(colData.Name,'Dimensions')
                colData=getRowDataForDimensionField(tableData,colData);
            elseif(slfeature('EnableStoredIntMinMax')>=2&&Simulink.data.isStoredIntProperty(colData.Name))
                colData=getRowDataForStoredIntField(tableData,colData,wsObj);
            else
                colData.Value=getPropValue(tableData,colData.Name);
            end

            rowData{colidx}=colData;%#ok
        end
    end

end


function cols=getColumnForGivenTable(h,isBpFromALUTObj,tableData,wsObj,ignoreStoredIntColumn)
    if isBpFromALUTObj
        cols=getColumnsForBreakpointTable(h,tableData,wsObj,ignoreStoredIntColumn);
    else
        cols=getColumnForLookupTable(tableData,wsObj,ignoreStoredIntColumn);
    end

    cols=lookuptableddg_hideTunableSizeNameColumn(h,isBpFromALUTObj,cols,'TunableSizeName');

    cols=getColumnAdjustedForLUTWidget(h,cols);

end


function cols=getColumnsForBreakpointTable(h,tableData,wsObj,ignoreStoredIntColumn)
    cols={'Name'};
    if~isequal(h.DialogData.BreakpointsSpecification,'Reference')
        cols=getPossibleProperties(tableData)';
    end
    if(~ignoreStoredIntColumn)
        cols=Simulink.data.filterStoredIntProperties(tableData,cols,wsObj);
    end

end


function cols=getColumnForLookupTable(tableData,wsObj,ignoreStoredIntColumn)
    cols=getPossibleProperties(tableData)';
    if(~ignoreStoredIntColumn)
        cols=Simulink.data.filterStoredIntProperties(tableData,cols,wsObj);
    end

end


function cols=getColumnAdjustedForLUTWidget(h,cols)




    usingLUTWidget=isUsingLUTWidgetOnEditor(h);
    if usingLUTWidget
        cols(ismember(cols,'FieldName'))=[];
        cols=['FieldName',cols];

        cols(ismember(cols,'Value'))=[];
    end

end


function rowData=getRowDataForReferenceBreakpoint(tableData,cols)
    rowData={};
    colData=[];
    colcount=length(cols);

    if(isempty(tableData))
        for colidx=1:colcount
            colData.Name=cols{colidx};
            colData.Alignment=6;

            if isequal(colData.Name,'Name')
                colData.Enabled=true;
                colData.Editable=true;
            else
                colData.Enabled=false;
                colData.Editable=false;
            end
            colData.Type='edit';
            rowData{colidx}=colData;%#ok

        end
    else
        for colidx=1:colcount
            colData.Name=cols{colidx};
            colData.Alignment=6;
            if isequal(colData.Name,'Name')
                colData.Enabled=true;
                colData.Editable=true;
                colData.Value=tableData;
            else
                colData.Enabled=false;
                colData.Editable=false;
                colData.Value='';
            end
            colData.Type='edit';
            rowData{colidx}=colData;%#ok
        end
    end
end


function colData=getRowDataForDataTypeField(hProxy,tableData,colData,supportEnumType)
    colData.Type='combobox';
    dataTypeItemsToSkip={'boolean'};
    dataTypeItems.builtinTypes={};
    builtInItemsList=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('LookupTable');
    for i=1:length(builtInItemsList)
        if(~ismember(builtInItemsList{i},dataTypeItemsToSkip))
            dataTypeItems.builtinTypes=[dataTypeItems.builtinTypes,builtInItemsList{i}];
        end
    end
    if(supportEnumType)
        dataTypeItems.supportsEnumType=true;
    else
        dataTypeItems.supportsEnumType=false;
    end
    dataTypeItems.supportsBusType=false;
    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    colData.Entries=Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dataTypeItems,hProxy);
    colData.Value=tableData.DataType;


    if~isequal(tableData.DataType,colData.Entries{1})
        colData.Entries=[tableData.DataType,colData.Entries];
    end
    colData.Entries=unique(colData.Entries,'stable');
    colData.Editable=true;
end

function colData=getRowDataForValueField(h,tableData,colData,isBpFromALUTObj,rowIdx)
    if(~isBpFromALUTObj&&isfield(h.DialogData,'table'))
        try
            if(isequal(h.DialogData.table{1}.Name,'Value'))
                colData.Value=h.DialogData.table{1}.Value;
            else
                colData.Value=getPropValue(tableData,colData.Name);
            end
        catch
            colData.Value=getPropValue(tableData,colData.Name);
        end
    else
        try
            if isfield(h.DialogData,'bp')&&isequal(getPropValue(tableData,colData.Name),slprivate('evalInEmptyWorkspace',h.DialogData.bp{rowIdx,1}.Value))
                colData.Value=h.DialogData.bp{rowIdx,1}.Value;
            else
                colData.Value=getPropValue(tableData,colData.Name);
            end
        catch
            colData.Value=getPropValue(tableData,colData.Name);
        end
    end
end


function colData=getRowDataForDimensionField(tableData,colData)
    if ischar(tableData.Dimensions)

        colData.Value=['''',getPropValue(tableData,colData.Name),''''];
    else
        colData.Value=getPropValue(tableData,colData.Name);
    end

end


function colData=getRowDataForStoredIntField(tableData,colData,wsObj)



    colData.Value=Simulink.data.convertRealWorldToStoredIntegerValue(tableData,colData.Name,wsObj);
    if~isempty(colData.Value)
        colData.Enabled=true;
        colData.Visible=true;
    else
        colData.Value='-';
        colData.Enabled=false;
        colData.Visible=false;
    end
end


