function dlgstruct=lookuptableddg(hProxy,name,varargin)





    [hProxy,h,wsObj,ownedByModel,uniqueTagName]=initializeHandleAndWksObjectAndDialogData(hProxy,name,varargin{:});

    if isempty(h)
        return;
    end

    [h,allTabs]=drawTableBreakpoints(hProxy,h,wsObj,name,uniqueTagName,ownedByModel);

    [grpUserData,tabUserData]=get_userdata_prop_grp(h);

    dlgstruct=addTabsForLUT(hProxy,h,name,uniqueTagName,allTabs,grpUserData,tabUserData);

    h.DialogData.TableValueDirty=false;
end


function tableData=fillTableInfo(hProxy,h,wsObj)
    isBpFromALUTObj=false;
    supportEnumType=false;
    tableData=[lookuptableddg_addData(hProxy,h.DialogData.Table,1,isBpFromALUTObj,supportEnumType,wsObj)];

end

function bptableData=fillBreakpointInfo(hProxy,h,name,wsObj)


    if(isempty(h.Breakpoints)&&~isequal(h.BreakpointsSpecification,'Reference'))
        error(DAStudio.message('Simulink:Data:LUT_Invalid_LUTObject_EmptyBreakpointVector',name));
    end

    bptableData={};
    isBpFromALUTObj=true;
    rowcount=length(h.DialogData.Breakpoints);
    if(isequal(h.DialogData.BreakpointsSpecification,'Reference')&&(rowcount==0))
        supportEnumType=false;
        bptableData=[bptableData;lookuptableddg_addData(hProxy,h.DialogData.Breakpoints,1,isBpFromALUTObj,supportEnumType,wsObj)];
    else
        bpSpecIsExplicitValues=isequal(h.DialogData.BreakpointsSpecification,'Explicit values');
        bpSpecIsReference=isequal(h.DialogData.BreakpointsSpecification,'Reference');
        storedIntColRequired=false;
        for rowidx=1:rowcount
            dtObj=Simulink.data.getDataTypeObjIfFixpt(h.DialogData.Breakpoints(rowidx),wsObj);
            if~isempty(dtObj)
                storedIntColRequired=true;
                break;
            end
        end
        for rowidx=1:rowcount
            if(~bpSpecIsReference)

                bptableData=[bptableData;lookuptableddg_addData(hProxy,h.DialogData.Breakpoints(rowidx),rowidx,isBpFromALUTObj,bpSpecIsExplicitValues,wsObj,storedIntColRequired)];%#ok
            else
                supportEnumType=false;
                bptableData=[bptableData;lookuptableddg_addData(hProxy,h.DialogData.Breakpoints{rowidx},rowidx,isBpFromALUTObj,supportEnumType,wsObj,storedIntColRequired)];%#ok
            end
            h.DialogData.BPValueDirty(rowidx)=false;
            h.DialogData.BPFirstpointValueDirty(rowidx)=false;
            h.DialogData.BPSpacingValueDirty(rowidx)=false;
        end
    end

end


function propList=get_property_list(h)%#ok
    propList=Simulink.data.getPropList(h,'GetAccess','public');
end

function tableCurrentItemChangedCallback(dlg,~,~)
    dlg.enableApplyButton(true);
end

function lutWidgetItemChangedCallback(DialogObjectName)
    dlg=findDDGByTag(DialogObjectName);
    for i=1:length(dlg)
        dlg(i).enableApplyButton(true);
    end
end

function tableDataChangedCallback(dlg,row,col,value)
    source=dlg.getSource;
    obj=source.getForwardedObject;
    [obj,wsObj]=l_getWSObject(source,obj);

    if~isempty(obj)
        source=obj;
    end

    data=source.DialogData.table;

    if isequal(data{row+1,col+1}.Name,'DataType')&&...
        strcmp(value,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))

        slprivate('slGetUserDataTypesFromWSDD',...
        source,[],[],true);
        dlg.setTableItemValue('dataTable_tag',row,col,data{row+1,col+1}.Value);
        dlg.refresh();
    elseif Simulink.data.isStoredIntProperty(data{row+1,col+1}.Name)
        tbl=source.DialogData.Table;
        realWorldVal=Simulink.data.convertStoredIntegerToRealWorldValue(tbl,value,wsObj);
        propName=extractAfter(data{row+1,col+1}.Name,'StoredInt');
        setPropValue(tbl,propName,realWorldVal);
        data{row+1,col+1}.Value=value;
        source.DialogData.table=data;
        source.DialogData.Table=tbl;
        dlg.refresh();
    else
        tbl=source.DialogData.Table;
        try
            setPropValue(tbl,data{row+1,col+1}.Name,value);
        catch ME
        end

        if isequal(data{row+1,col+1}.Name,'Value')
            source.DialogData.TableValueDirty=true;
            [datarows,datacols]=size(data);%#ok
            for colidx=1:datacols
                if isequal(data{row+1,colidx}.Name,'Dimensions')
                    newDim=getPropValue(tbl,'Dimensions');
                    dlg.setTableItemValue('dataTable_tag',row,colidx-1,newDim);
                    break;
                end
            end
        elseif(isequal(data{row+1,col+1}.Name,'DataType')||...
            isequal(data{row+1,col+1}.Name,'Min')||...
            isequal(data{row+1,col+1}.Name,'Max'))

            dlg.refresh();
        elseif(isequal(data{row+1,col+1}.Name,'Unit'))

            if isUsingLUTWidget(source)
                updateLUTWTableUnit(source,value);
            end
        elseif(isequal(data{row+1,col+1}.Name,'FieldName'))

            if isUsingLUTWidget(source)
                updateLUTWTableFieldName(source,value);
            end
        elseif(isequal(data{row+1,col+1}.Name,'Description'))

            if isUsingLUTWidget(source)
                updateLUTWTableDescription(source,value);
            end
        end
        data{row+1,col+1}.Value=value;
        source.DialogData.table=data;
        source.DialogData.Table=tbl;
        if isequal(data{row+1,col+1}.Name,'FieldName')
            lookuptableddg_cb(dlg,data{row+1,col+1}.Name,data{row+1,col+1}.Value);
        end
    end
end


function breakpointDataChangedCallback(dlg,row,col,value)

    source=dlg.getSource;
    obj=source.getForwardedObject;
    [obj,wsObj]=l_getWSObject(source,obj);

    if~isempty(obj)
        source=obj;
    end

    data=source.DialogData.bp;
    bps=source.DialogData.Breakpoints;

    bpSpecsFormat=obj.DialogData.BreakpointsSpecification;

    if(~isequal(bpSpecsFormat,'Reference'))
        if(row+1)>length(bps)
            bp=Simulink.lookuptable.Breakpoint;
        else
            bp=bps(row+1);
        end

        if isequal(data{row+1,col+1}.Name,'DataType')&&...
            strcmp(value,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))

            slprivate('slGetUserDataTypesFromWSDD',...
            source,[],[],true);
            dlg.setTableItemValue('breakPointsTable_tag',row,col,data{row+1,col+1}.Value);
            dlg.refresh();
        elseif Simulink.data.isStoredIntProperty(data{row+1,col+1}.Name)
            realWorldVal=Simulink.data.convertStoredIntegerToRealWorldValue(bp,value,wsObj);
            propName=extractAfter(data{row+1,col+1}.Name,'StoredInt');
            setPropValue(bp,propName,realWorldVal);
            data{row+1,col+1}.Value=value;
            source.DialogData.bp=data;
            bps(row+1)=bp;
            source.DialogData.Breakpoints=bps;
            dlg.refresh();
        else
            try
                setPropValue(bp,data{row+1,col+1}.Name,value);
            catch ME
            end
            if(isequal(bpSpecsFormat,'Explicit values')&&...
                isequal(data{row+1,col+1}.Name,'Value'))
                source.DialogData.BPValueDirty(row+1)=true;
                [datarows,datacols]=size(data);%#ok
                for colidx=1:datacols
                    if isequal(data{row+1,colidx}.Name,'Dimensions')
                        newDim=getPropValue(bp,'Dimensions');
                        dlg.setTableItemValue('breakPointsTable_tag',row,colidx-1,newDim);
                        break;
                    end
                end
            elseif(isequal(bpSpecsFormat,'Even spacing')&&...
                (isequal(data{row+1,col+1}.Name,'FirstPoint')||...
                isequal(data{row+1,col+1}.Name,'Spacing')))

                source.DialogData.BPFirstpointValueDirty(row+1)=...
                source.DialogData.BPFirstpointValueDirty(row+1)||...
                isequal(data{row+1,col+1}.Name,'FirstPoint');
                source.DialogData.BPSpacingValueDirty(row+1)=...
                source.DialogData.BPSpacingValueDirty(row+1)||...
                isequal(data{row+1,col+1}.Name,'Spacing');
            elseif(isequal(data{row+1,col+1}.Name,'DataType')||...
                isequal(data{row+1,col+1}.Name,'Min')||...
                isequal(data{row+1,col+1}.Name,'Max'))

                dlg.refresh();
            elseif(isequal(data{row+1,col+1}.Name,'Unit'))

                if isUsingLUTWidget(source)
                    updateLUTWAxisUnit(source,row+1,value);
                end
            elseif(isequal(data{row+1,col+1}.Name,'FieldName'))

                if isUsingLUTWidget(source)
                    updateLUTWAxisFieldName(source,row+1,value);
                end
            elseif(isequal(data{row+1,col+1}.Name,'Description'))

                if isUsingLUTWidget(source)
                    updateLUTWAxisDescription(source,row+1,value);
                end
            end

            data{row+1,col+1}.Value=value;
            source.DialogData.bp=data;
            bps(row+1)=bp;
            source.DialogData.Breakpoints=bps;
        end
    else
        assert(isequal(obj.DialogData.BreakpointsSpecification,'Reference'));
        if(row+1)>length(source.DialogData.Breakpoints)
            source.DialogData.Breakpoints={source.DialogData.Breakpoints;value};
        else
            source.DialogData.Breakpoints{row+1}=value;
        end
    end
end


function[obj,wsObj]=l_getWSObject(source,obj)
    wsObj=[];
    if isa(source,'Simulink.SlidDAProxy')
        slidObj=source.getObject();
        modelRootObj=get_param(slidObj.System.Handle,'Object');
        obj=source.getForwardedObject;
        wsObj=modelRootObj.getWorkspace();

    elseif isa(source,'wsDDGSource')
        ddgSource=source.getForwardedObject();
        if isa(ddgSource,'Simulink.SlidDAProxy')
            slidObj=ddgSource.getObject();
            modelRootObj=get_param(slidObj.System.Handle,'Object');
            obj=ddgSource.getForwardedObject;
            wsObj=modelRootObj.getWorkspace();
        else
            obj=ddgSource;
        end

    elseif isa(source,'Simulink.dd.EntryDDGSource')
        dd=Simulink.data.dictionary.open(source.m_originalDataSource);
        wsObj=dd.getSection(source.m_scope);

    end

end




function idx=getRowIdx(varargin)
    persistent rowIdx;
    if nargin>0&&varargin{1}
        rowIdx=0;
    end
    if nargin>1
        rowIdx=rowIdx+varargin{2};
    end
    idx=rowIdx;
end

function[h,allTabs]=drawTableBreakpoints(hProxy,h,wsObj,name,uniqueTagName,ownedByModel)
    getRowIdx(true);
    [h,tableBreakpointsTab]=drawTableBreakpointsTab(hProxy,h,wsObj,name,uniqueTagName,ownedByModel);

    [h,codeGenerationTab]=drawCodeGenerationTab(hProxy,h,wsObj,ownedByModel);

    [h,advancedTab]=drawAdvancedTab(h);

    allTabs={};
    allTabs=[allTabs,tableBreakpointsTab,codeGenerationTab,advancedTab];
end


function[h,tabletab]=drawTableBreakpointsTab(hProxy,h,wsObj,name,uniqueTagName,ownedByModel)






    [h,tabletabA,tabletabB,tabletabC,modelArgumentCheckbox,lutWidget]=drawTableBreakpointsTabElements(hProxy,h,wsObj,name,uniqueTagName,ownedByModel);

    tabletab.Items=[tabletabA.Items,tabletabB,tabletabC,modelArgumentCheckbox,lutWidget];
    tabletab.Name=DAStudio.message('Simulink:dialog:TableAndBreakpointsTab');
    currRowIdx=getRowIdx();
    tabletab.LayoutGrid=[currRowIdx,5];
    tabletab.RowStretch=[zeros(1,currRowIdx-1),1];
    tabletab.ColStretch=[0,0,0,0,1];
    tabletab.Tag='TabOne';

end

function[h,tabletabA,tabletabB,tabletabC,modelArgumentCheckbox,lutWidget]=drawTableBreakpointsTabElements(hProxy,h,wsObj,name,uniqueTagName,ownedByModel)

    usingLUTWidget=isUsingLUTWidget(h);
    [h,bpDataSz]=setupBreakpointDataAndDimensionSync(hProxy,h,name,wsObj);
    [h,tabletabA]=drawTableBreakpointsTabPartA(h,wsObj,bpDataSz);
    [h,tabletabB]=drawTableBreakpointsTabPartB(hProxy,h,wsObj);
    [h,tabletabC]=drawTableBreakpointsTabPartC(h,wsObj);
    [modelArgumentCheckbox]=drawModelArgumentCheckbox(hProxy,ownedByModel);
    [lutWidget]=drawLUTWidget(h,usingLUTWidget,uniqueTagName);

end

function[h,bpDataSz]=setupBreakpointDataAndDimensionSync(hProxy,h,name,wsObj)


    data=fillBreakpointInfo(hProxy,h,name,wsObj);

    if isvector(h.Table.Value)||isempty(h.Table.Value)
        tableDataSz=1;
    else
        tableDataSz=numel(size(h.Table.Value));
    end

    if isempty(h.DialogData)||~isfield(h.DialogData,'bp')||isempty(h.DialogData.bp)




        isBpFromALUTObj=true;
        [bpDataSz,~]=size(data);
        if tableDataSz>bpDataSz
            for count=(bpDataSz+1):tableDataSz
                if isequal(h.DialogData.BreakpointsSpecification,'Reference')
                    bp=['BP',num2str(count)];
                    supportEnumType=false;
                    data=[data;lookuptableddg_addData(hProxy,bp,count,isBpFromALUTObj,supportEnumType)];%#ok
                    h.DialogData.Breakpoints{count}=bp;
                elseif isequal(h.DialogData.BreakpointsSpecification,'Explicit values')
                    bp=Simulink.lookuptable.Breakpoint.Create(int32(count));
                    supportEnumType=true;
                    data=[data;lookuptableddg_addData(hProxy,bp,count,isBpFromALUTObj,supportEnumType)];%#ok
                    h.DialogData.Breakpoints(count)=bp;
                elseif isequal(h.DialogData.BreakpointsSpecification,'Even spacing')
                    bp=Simulink.lookuptable.Evenspacing.Create(int32(count));
                    supportEnumType=false;
                    data=[data;lookuptableddg_addData(hProxy,bp,count,isBpFromALUTObj,supportEnumType)];%#ok
                    h.DialogData.Breakpoints(count)=bp;
                end
            end
            bpDataSz=tableDataSz;
        end
    else
        bpDataSz=length(h.DialogData.Breakpoints);
    end

    h.DialogData.bp=data;


end

function[h,tabletabA]=drawTableBreakpointsTabPartA(h,wsObj,bpDataSz)



    NumDimsLabel.Name=DAStudio.message('Simulink:dialog:LookupTableNumberOfTableDimensionsPrompt');
    NumDimsLabel.Type='text';
    NumDimsLabel.Tag='NumDimsLabel_tag';
    rowIdx=getRowIdx(false,1);
    NumDimsLabel.RowSpan=[rowIdx,rowIdx];
    NumDimsLabel.ColSpan=[1,1];

    spacer1.Name='';
    spacer1.Type='text';
    spacer1.RowSpan=[rowIdx,rowIdx];
    spacer1.ColSpan=[2,2];

    BPSpecificationLabel.Name=DAStudio.message('Simulink:blkprm_prompts:BreakpointsSpecificationLookupND');
    BPSpecificationLabel.Type='text';
    BPSpecificationLabel.Tag='BPSpecificationLabel_tag';
    BPSpecificationLabel.RowSpan=[rowIdx,rowIdx];
    BPSpecificationLabel.ColSpan=[3,3];

    rowIdx=getRowIdx(false,1);
    dataDimensions.Name=DAStudio.message('Simulink:dialog:LookupTableNumberOfTableDimensionsPrompt');
    dataDimensions.HideName=1;
    dataDimensions.Tag='dimensions_tag';
    dataDimensions.Type='spinbox';
    dataDimensions.RowSpan=[rowIdx,rowIdx];
    dataDimensions.ColSpan=[1,1];
    dataDimensions.DialogRefresh=1;
    dataDimensions.Editable=1;
    dataDimensions.Range=[1,30];
    dataDimensions.Value=bpDataSz;
    dataDimensions.MatlabMethod='lookuptableddg_cb';
    dataDimensions.MatlabArgs={'%dialog','%tag','%value',wsObj};
    h.DialogData.DataDimensions=dataDimensions;

    breakPointsSpecification.Name=DAStudio.message('Simulink:dialog:LookupTableBreakpointsSpecificationPrompt');
    breakPointsSpecification.HideName=1;

    breakPointsSpecification.Type='combobox';
    breakPointsSpecification.Source=h;
    breakPointsSpecification.ObjectProperty='BreakpointsSpecification';
    breakPointsSpecification.Entries=getPropAllowedValues(h,breakPointsSpecification.ObjectProperty);
    breakPointsSpecification.Tag='breakpointsspecification_tag';
    breakPointsSpecification.RowSpan=[rowIdx,rowIdx];
    breakPointsSpecification.ColSpan=[3,3];
    breakPointsSpecification.DialogRefresh=1;
    breakPointsSpecification.Editable=1;
    breakPointsSpecification.MatlabMethod='lookuptableddg_cb';
    breakPointsSpecification.MatlabArgs={'%dialog','%tag','%value',wsObj};

    if(slfeature('VariableSizeLookupTables')>0)
        tabletabA.Items={
        NumDimsLabel,...
        spacer1,...
        BPSpecificationLabel,...
        dataDimensions,...
        breakPointsSpecification};
    else

        [spacer2,supportTunableSizeCheckBox,spacer3]=createSupportTunableSizeWidgetVarSizeFeatOff(h,rowIdx);

        tabletabA.Items={
        NumDimsLabel,...
        spacer1,...
        BPSpecificationLabel,...
        dataDimensions,...
        breakPointsSpecification,...
        spacer2,...
        supportTunableSizeCheckBox,...
        spacer3};
    end

end


function[h,tabletabB]=drawTableBreakpointsTabPartB(hProxy,h,wsObj)


    dataTable.Name=DAStudio.message('Simulink:dialog:LookupTableDataGroup');
    dataTable.Tag='dataTable_tag';
    dataTable.Type='table';
    dataTable.MaximumSize=[-1,100];
    dataTable.CurrentItemChangedCallback=@tableCurrentItemChangedCallback;
    dataTable.ValueChangedCallback=@tableDataChangedCallback;
    data=fillTableInfo(hProxy,h,wsObj);
    dataTable.Data=data;

    h.DialogData.table=data;
    dataTable.ColHeader=fillTableColumnHeaders(h,wsObj);
    dataTable.ColumnCharacterWidth=[];

    count=length(dataTable.ColHeader);
    defaultValueWidth=20;
    for idx=1:count
        if isequal(dataTable.Data{idx}.Name,'Value')
            colWidth=defaultValueWidth;
        elseif isequal(dataTable.Data{idx}.Name,'DataType')
            colWidth=17;
        else
            colWidth=length(dataTable.ColHeader{idx});
        end
        dataTable.ColumnCharacterWidth=[dataTable.ColumnCharacterWidth,...
        colWidth];
    end

    dataTable.Size=[1,length(dataTable.ColHeader)];
    dataTable.Grid=1;
    dataTable.HeaderVisibility=[1,1];
    dataTable.PreferredSize=[-1,50];

    rowIdx=getRowIdx(false,1);
    dataTable.RowSpan=[rowIdx,rowIdx];

    dataTable.ColSpan=[1,5];
    dataTable.DialogRefresh=1;
    dataTable.Editable=1;
    dataTable.MatlabMethod='lookuptableddg_cb';
    dataTable.MatlabArgs={'%dialog','%tag','%value',wsObj};

    tabletabB=dataTable;

end


function[h,tabletabC]=drawTableBreakpointsTabPartC(h,wsObj)

    breakPointsTable.Name=DAStudio.message('Simulink:dialog:BreakpointsTablePrompt');
    breakPointsTable.Tag='breakPointsTable_tag';
    breakPointsTable.Type='table';


    breakPointsTable.Data=h.DialogData.bp;
    breakPointsTable.ColHeader=fillBreakpointColumnHeaders(h,wsObj);
    breakPointsTable.ColumnCharacterWidth=[];
    defaultValueWidth=20;
    count=length(breakPointsTable.ColHeader);
    for idx=1:count
        if isequal(h.DialogData.BreakpointsSpecification,'Reference')
            colWidth=3*length(breakPointsTable.ColHeader{1,idx});
        elseif~isequal(h.DialogData.BreakpointsSpecification,'Reference')&&isequal(breakPointsTable.Data{1,idx}.Name,'Value')
            colWidth=defaultValueWidth;
        elseif~isequal(h.DialogData.BreakpointsSpecification,'Reference')&&isequal(breakPointsTable.Data{1,idx}.Name,'FirstPoint')
            colWidth=10;
        elseif~isequal(h.DialogData.BreakpointsSpecification,'Reference')&&isequal(breakPointsTable.Data{1,idx}.Name,'Spacing')
            colWidth=10;
        elseif isequal(breakPointsTable.Data{1,idx}.Name,'DataType')
            colWidth=17;
        else
            colWidth=length(breakPointsTable.ColHeader{1,idx});
        end
        breakPointsTable.ColumnCharacterWidth=[breakPointsTable.ColumnCharacterWidth,colWidth];
    end


    [rowCount,colCount]=size(breakPointsTable.Data);%#ok
    breakPointsTable.Size=[rowCount,length(breakPointsTable.ColHeader)];
    breakPointsTable.Grid=1;
    breakPointsTable.HeaderVisibility=[1,1];
    breakPointsTable.PreferredSize=[-1,100];
    rowIdx=getRowIdx(false,1);
    breakPointsTable.RowSpan=[rowIdx,rowIdx];
    breakPointsTable.ColSpan=[1,5];
    breakPointsTable.DialogRefresh=1;
    breakPointsTable.Editable=1;
    breakPointsTable.CurrentItemChangedCallback=@tableCurrentItemChangedCallback;
    breakPointsTable.ValueChangedCallback=@breakpointDataChangedCallback;

    tabletabC=breakPointsTable;

end


function[modelArgumentCheckbox]=drawModelArgumentCheckbox(hProxy,ownedByModel)


    modelArgumentCheckbox=[];
    if ownedByModel
        argument.Name=DAStudio.message('Simulink:dialog:ArgumentText');
        argument.ObjectProperty='Argument';
        argument.Tag='chkArgument';
        argument.Type='checkbox';
        argument.Source=hProxy;
        argument.Enabled=true;
        if hProxy.isReadonlyProperty('Argument')
            argument.Enabled=false;
        end
        argument.Mode=true;
        argument.DialogRefresh=true;
        rowIdx=getRowIdx(false,1);
        argument.RowSpan=[rowIdx,rowIdx];
        argument.ColSpan=[1,4];

        modelArgumentCheckbox=argument;
    end
end



function[h,codeGenerationTab]=drawCodeGenerationTab(hProxy,h,wsObj,ownedByModel)
    codeGenRowIdx=1;
    [h,grpCodeGen]=drawCodeGenerationTabElements(hProxy,h,wsObj,ownedByModel,codeGenRowIdx);
    if~isempty(grpCodeGen)
        grpCodeGen.Name="";
        grpCodeGen.RowSpan=[1,1];
        grpCodeGen.ColStretch=[1,1];


        codeGenerationTab.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        codeGenerationTab.LayoutGrid=[1,5];
        codeGenerationTab.RowStretch=[0,1];
        codeGenerationTab.ColStretch=[0,0,1,1,1];
        codeGenerationTab.Tag='TabTwo';
        codeGenerationTab.Items={grpCodeGen};
    end
end

function[h,grpCodeGen]=drawCodeGenerationTabElements(hProxy,h,wsObj,ownedByModel,codeGenRowIdx)




    grpNumItems=0;
    grpTypeDef.Name=DAStudio.message('Simulink:dialog:DataTypeGenOptionsPrompt');
    grpTypeDef.Type='group';
    grpTypeDef.Tag='grpTypeDef_tag';
    grpTypeDef.RowSpan=[3,3];
    grpTypeDef.ColSpan=[1,2];
    grpTypeDef.LayoutGrid=[3,2];
    grpTypeDef.ColStretch=[1,1];

    grpTypeDef.Items={};
    grpTypeDef.Source=h.DialogData.StructTypeInfo;

    fldname=h.Table.FieldName;%#ok
    if isfield(h.DialogData,'table')
        if isfield(h.DialogData.table,'FieldName')
            fldname=h.DialogData.table.FieldName;%#ok
        elseif isfield(h.DialogData,'Table')
            fldname=h.DialogData.Table.FieldName;%#ok
        end
    end


    grpTypeDef.Enabled=true;








    grpNumItems=grpNumItems+1;
    typeNameLbl.Name=DAStudio.message('Simulink:dialog:StructtypeStructName');
    typeNameLbl.Type='text';
    typeNameLbl.Tag='typeNameLbl';
    typeNameLbl.RowSpan=[grpNumItems,grpNumItems];
    typeNameLbl.ColSpan=[1,1];

    typeName.Name=DAStudio.message('Simulink:dialog:StructtypeStructName');
    typeName.HideName=1;
    typeName.RowSpan=[grpNumItems,grpNumItems];
    typeName.ColSpan=[2,2];
    typeName.Type='edit';
    typeName.Tag='typeName_tag';
    typeName.ObjectProperty='Name';

    typeName.MatlabMethod='lookuptableddg_cb';
    typeName.MatlabArgs={'%dialog','grpTypeDef_tag',typeName.ObjectProperty,'%value',wsObj};





    grpNumItems=grpNumItems+1;
    dataScopeLbl.Name=DAStudio.message('Simulink:dialog:StructtypeDataScopeLblName');
    dataScopeLbl.Type='text';
    dataScopeLbl.Tag='dataScopeLbl';
    dataScopeLbl.RowSpan=[grpNumItems,grpNumItems];
    dataScopeLbl.ColSpan=[1,1];

    dataScope.Name=DAStudio.message('Simulink:dialog:StructtypeDataScopeLblName');
    dataScope.HideName=1;
    dataScope.RowSpan=[grpNumItems,grpNumItems];
    dataScope.ColSpan=[2,2];
    dataScope.Type='combobox';
    dataScope.Tag='dataScope_tag';
    dataScope.ObjectProperty='DataScope';
    dataScope.Entries=getPropAllowedValues(grpTypeDef.Source,dataScope.ObjectProperty);

    dataScope.MatlabMethod='lookuptableddg_cb';
    dataScope.MatlabArgs={'%dialog','grpTypeDef_tag',dataScope.ObjectProperty,'%value',dataScope.Entries,wsObj};




    grpNumItems=grpNumItems+1;
    headerFileLbl.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
    headerFileLbl.Type='text';
    headerFileLbl.Tag='HeaderFileLbl';
    headerFileLbl.RowSpan=[grpNumItems,grpNumItems];
    headerFileLbl.ColSpan=[1,1];

    headerFile.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
    headerFile.HideName=1;
    headerFile.RowSpan=[grpNumItems,grpNumItems];
    headerFile.ColSpan=[2,2];
    headerFile.Type='edit';
    headerFile.Tag='headerFile_tag';
    headerFile.ObjectProperty='HeaderFileName';

    headerFile.MatlabMethod='lookuptableddg_cb';
    headerFile.MatlabArgs={'%dialog','grpTypeDef_tag',headerFile.ObjectProperty,'%value'};


    grpTypeDef.Items={typeNameLbl,typeName,...
    dataScopeLbl,dataScope,...
    headerFileLbl,headerFile};
    grpTypeDef.ColStretch=[0,1];

    grpTypeDef.Enabled=~isequal(h.DialogData.BreakpointsSpecification,'Reference');
    grpTypeDef.Visible=~isequal(h.DialogData.BreakpointsSpecification,'Reference');





    grpDataDef=createCodeGenGroup(hProxy,...
    'Simulink:dialog:LookupTableCoderInfoGroupPrompt',...
    'Simulink:dialog:DataStorageClassToolTip2');
    grpDataDef.RowSpan=[1,1];

    grpDataDef.Visible=true;





    if ownedByModel&&slfeature('ModelOwnedDataIM')>0
        grpCodeBtn=createCodeGenBtn(hProxy,...
        'Simulink:dialog:LookupTableCoderInfoGroupPrompt',...
        'Simulink:dialog:ConfigureTextToolTipLookupTable',...
        'LookupTable');
        codeGenRowIdx=codeGenRowIdx+1;
        grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        grpCodeGen.Type='group';
        grpCodeGen.Tag='grpCodeGen_tag';
        grpCodeGen.RowSpan=[codeGenRowIdx,codeGenRowIdx];
        grpCodeGen.ColSpan=[1,5];

        if~isempty(grpCodeBtn.Items)
            grpCodeGen.LayoutGrid=[1,1];
            grpCodeGen.Items={grpCodeBtn,grpTypeDef};
        elseif grpTypeDef.Visible
            grpCodeGen.LayoutGrid=[1,1];
            grpCodeGen.Items={grpTypeDef};
        else
            grpCodeGen={};
        end
    else
        codeGenRowIdx=codeGenRowIdx+1;
        grpCodeGen.LayoutGrid=[2,2];
        grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        grpCodeGen.Type='group';
        grpCodeGen.Tag='grpCodeGen_tag';
        grpCodeGen.RowSpan=[codeGenRowIdx,codeGenRowIdx];
        grpCodeGen.ColSpan=[1,5];

        grpCodeGen.Items={grpDataDef,grpTypeDef};
    end

end

function[h,advancedTab]=drawAdvancedTab(h)

    if strcmp(h.DialogData.BreakpointsSpecification,'Reference')||...
        (slfeature('VariableSizeLookupTables')==0)




        advancedTab={};
        return;
    end


    rowIdx=1;
    [h,grpAdvancedSize]=drawAdvancedTabElements(h,rowIdx);
    advancedTab.Name=DAStudio.message('Simulink:dialog:DataAdvancedOptionsPrompt');
    advancedTab.LayoutGrid=[1,1];
    advancedTab.RowStretch=[0,1];
    advancedTab.ColStretch=[0,1];
    advancedTab.Tag='TabLUTAdvanced';
    advancedTab.Items={grpAdvancedSize};
end


function[h,grpAdvancedSize,rowIdx]=drawAdvancedTabElements(h,rowIdx)





    [allowDifferentlySizedArrays,rowIdx]=createAllowDifferentlySizedArraysWidget(h,rowIdx);



    supportTunableSize_dummy=createDummySupportTunableSizeWidget(h,rowIdx);


    [supportTunableSize,rowIdx]=createSupportTunableSizeWidget(h,rowIdx);

    grpAdvancedSize.Name="";
    grpAdvancedSize.RowSpan=[1,1];
    grpAdvancedSize.ColSpan=[1,1];
    grpAdvancedSize.ColStretch=[1,1];
    grpAdvancedSize.LayoutGrid=[rowIdx,1];
    grpAdvancedSize.Type='group';
    grpAdvancedSize.Tag='grpAdvancedSize_tag';

    grpAdvancedSize.Items={
    allowDifferentlySizedArrays,supportTunableSize,supportTunableSize_dummy};
end

function[allowDifferentlySizedArrays,rowIdx]=createAllowDifferentlySizedArraysWidget(h,rowIdx)

    allowDifferentlySizedArrays.Name=DAStudio.message('Simulink:dialog:LookupTableAllowDifferentlySizedArraysPrompt');
    allowDifferentlySizedArrays.RowSpan=[rowIdx,rowIdx];
    allowDifferentlySizedArrays.ColSpan=[1,1];
    allowDifferentlySizedArrays.Type='checkbox';
    allowDifferentlySizedArrays.Tag='AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes_tag';
    allowDifferentlySizedArrays.Source=h;
    allowDifferentlySizedArrays.ObjectProperty='AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes';
    allowDifferentlySizedArrays.DialogRefresh=true;
    allowDifferentlySizedArrays.Mode=true;
    allowDifferentlySizedArrays.Visible=~strcmp(h.DialogData.BreakpointsSpecification,'Reference');
    allowDifferentlySizedArrays.Enabled=~strcmp(h.DialogData.BreakpointsSpecification,'Reference');
    rowIdx=rowIdx+1;
end

function[supportTunableSize_dummy]=createDummySupportTunableSizeWidget(h,rowIdx)


    supportTunableSize_dummy.Name=DAStudio.message('Simulink:dialog:LookupTableSupportTunableSizePrompt');
    supportTunableSize_dummy.Type='checkbox';
    supportTunableSize_dummy.Tag='supportTunableSize_dummy_tag';
    supportTunableSize_dummy.Value=true;
    supportTunableSize_dummy.RowSpan=[rowIdx,rowIdx];
    supportTunableSize_dummy.ColSpan=[1,1];
    supportTunableSize_dummy.DialogRefresh=true;
    supportTunableSize_dummy.Enabled=false;
    supportTunableSize_dummy.Visible=~strcmp(h.DialogData.BreakpointsSpecification,'Reference')&&...
    isequal(h.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes,1);
end

function[supportTunableSize,rowIdx]=createSupportTunableSizeWidget(h,rowIdx)

    supportTunableSize.Name=DAStudio.message('Simulink:dialog:LookupTableSupportTunableSizePrompt');
    supportTunableSize.RowSpan=[rowIdx,rowIdx];
    supportTunableSize.ColSpan=[1,1];
    supportTunableSize.Type='checkbox';
    supportTunableSize.Tag='supportTunableSize_tag';
    supportTunableSize.Source=h;
    supportTunableSize.ObjectProperty='SupportTunableSize';
    supportTunableSize.Visible=~strcmp(h.DialogData.BreakpointsSpecification,'Reference');
    supportTunableSize.Enabled=~strcmp(h.DialogData.BreakpointsSpecification,'Reference');


    supportTunableSize.Visible=supportTunableSize.Visible&&...
    ~isequal(h.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes,1);
    supportTunableSize.Enabled=supportTunableSize.Enabled&&...
    ~isequal(h.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes,1);

    rowIdx=rowIdx+1;

end

function[spacer2,supportTunableSize,spacer3]=createSupportTunableSizeWidgetVarSizeFeatOff(h,rowIdx)

    spacer2.Name='';
    spacer2.Type='text';
    spacer2.RowSpan=[rowIdx,rowIdx];
    spacer2.ColSpan=[4,4];


    supportTunableSize.Name=DAStudio.message('Simulink:dialog:LookupTableSupportTunableSizePrompt');
    supportTunableSize.RowSpan=[rowIdx,rowIdx];
    supportTunableSize.ColSpan=[5,5];
    supportTunableSize.Type='checkbox';
    supportTunableSize.Tag='supportTunableSize_tag';
    supportTunableSize.Source=h;
    supportTunableSize.ObjectProperty='SupportTunableSize';
    supportTunableSize.Visible=~isequal(h.DialogData.BreakpointsSpecification,'Reference');
    supportTunableSize.Enabled=~isequal(h.DialogData.BreakpointsSpecification,'Reference');

    spacer3.Name='';
    spacer3.Type='text';
    spacer3.RowSpan=[rowIdx,rowIdx];
    spacer3.ColSpan=[5,5];
    spacer3.PreferredSize=[131,-1];
    spacer3.Visible=isequal(h.DialogData.BreakpointsSpecification,'Reference');
end

function dlgOpenCallback(dlg)
    source=dlg.getSource;
    obj=source.getForwardedObject;
    [obj,wsObj]=l_getWSObject(source,obj);

    if~isempty(obj)
        source=obj;
    end
    if isUsingLUTWidget(source)
        if isLUTWidgetUICacheDifferentFromDialogDataCache(source)
            dlg.enableApplyButton(true);
        end
    end
end

function dlgstruct=addTabsForLUT(hProxy,h,name,uniqueTagName,allTabs,grpUserData,tabUserData)





    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.DialogTag=uniqueTagName;


    tabcont.Type='tab';
    tabcont.Tag='TabWhole';


    tabcont.Tabs=allTabs;
    if~isempty(grpUserData.Items)
        tabcont.Tabs{end+1}=tabUserData;
    end
    [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'LookupTable','TabUserDefined');
    if(~isempty(grpAdditional.Items))
        tabcont.Tabs{end+1}=tabAdditionalProp;
    end

    dlgstruct.Items={tabcont};


    if isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.isReadonlyProperty('Value')
        for i=1:numel(dlgstruct.Items)
            dlgstruct.Items{i}.Enabled=false;
        end
    end


    dlgstruct.LayoutGrid=allTabs{1}.LayoutGrid;


    dlgstruct.PreApplyCallback='lookuptableddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','preapply'};
    dlgstruct.PostApplyCallback='lookuptableddg_cb';
    dlgstruct.PostApplyArgs={'%dialog','postapply'};
    dlgstruct.PreRevertCallback='lookuptableddg_cb';
    dlgstruct.PreRevertArgs={'%dialog','prerevert'};
    dlgstruct.CloseCallback='lookuptableddg_cb';
    dlgstruct.CloseArgs={'%dialog','close'};


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_lookuptable'};

    dlgstruct.IgnoreESCClose=isUsingLUTWidget(h);
    dlgstruct.DefaultOk=~isUsingLUTWidget(h);


end

function[hProxy,h,wsObj,ownedByModel,uniqueTagName]=initializeHandleAndWksObjectAndDialogData(hProxy,name,varargin)

    if~isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.CoderInfo.HasContext
        hProxy=Simulink.SlidDAProxy(hProxy.getSlidParam);
    end

    if isa(hProxy,'Simulink.SlidDAProxy')
        h=hProxy.getForwardedObject;
        if isa(h,'Simulink.SlidDAProxy')
            h=h.getForwardedObject;
        end
        if isempty(h)
            return;
        end
        ownedByModel=true;
    else
        h=hProxy;
        ownedByModel=false;
    end

    ownedByDD=false;

    if nargin>=3
        if isa(varargin{1},'Simulink.data.dictionary.Section')
            ownedByDD=true;
        end
    end

    wsObj=[];
    ownerName='base';
    if ownedByModel
        slidObj=hProxy.getObject();
        modelRootObj=get_param(slidObj.System.Handle,'Object');
        wsObj=modelRootObj.getWorkspace();
        ownerName=wsObj.ownerName;
    elseif ownedByDD
        wsObj=varargin{1};
        ownerName=strsplit(varargin{2},'.');
        ownerName=ownerName{1};
    end

    uniqueTagName=getUniqueTagName(name,ownedByModel,ownedByDD,ownerName);


    h=initializeDialogData(h);


end

function uniqueTagName=getUniqueTagName(name,ownedByModel,ownedByDD,ownerName)

    if ownedByModel
        uniqueTagName=['lutoe_ws_',ownerName,'_',name];
    elseif ownedByDD
        uniqueTagName=['lutoe_dd_',ownerName,'_',name];
    else
        uniqueTagName=['lutoe_ws_',ownerName,'_',name];
    end

end


function h=initializeDialogData(h)

    if isempty(findprop(h,'DialogData'))
        hProp=addprop(h,'DialogData');
        hProp.Transient=true;
        hProp.Hidden=true;
    end

    if isempty(h.DialogData)||~isfield(h.DialogData,'BreakpointsSpecification')...
        ||isempty(h.DialogData.BreakpointsSpecification)
        h.DialogData.BreakpointsSpecification=h.BreakpointsSpecification;
    end

    if isempty(h.DialogData)||~isfield(h.DialogData,'Breakpoints')||isempty(h.DialogData.Breakpoints)
        h.DialogData.Breakpoints=h.Breakpoints;
    end

    if isempty(h.DialogData)||~isfield(h.DialogData,'Table')||isempty(h.DialogData.Table)
        h.DialogData.Table=h.Table;
    end

    if isempty(h.DialogData)||~isfield(h.DialogData,'StructTypeInfo')||isempty(h.DialogData.StructTypeInfo)
        h.DialogData.StructTypeInfo=h.StructTypeInfo;
    end

end

function updateLUTWTableUnit(source,unitValue)
    source.DialogData.WidgetData.Table.Unit=unitValue;
end

function updateLUTWTableFieldName(source,fieldnameValue)
    source.DialogData.WidgetData.Table.FieldName=fieldnameValue;
end

function updateLUTWTableDescription(source,descriptionVal)
    source.DialogData.WidgetData.Table.Description=descriptionVal;
end

function updateLUTWAxisUnit(source,AxisIdx,unitValue)
    source.DialogData.WidgetData.Axes(AxisIdx).Unit=unitValue;
end

function updateLUTWAxisFieldName(source,AxisIdx,fieldnameValue)
    source.DialogData.WidgetData.Axes(AxisIdx).FieldName=fieldnameValue;
end

function updateLUTWAxisDescription(source,AxisIdx,descriptionVal)
    source.DialogData.WidgetData.Axes(AxisIdx).Description=descriptionVal;
end

function usingLUTWidget=isUsingLUTWidget(h)
    usingLUTWidget=isUsingLUTWidgetOnEditor(h);
end

function isUICacheDirty=isLUTWidgetUICacheDifferentFromDialogDataCache(h)
    dialogData=h.DialogData;
    lutwidgetData=h.DialogData.WidgetData;
    isUICacheDirty=false;

    if~isequal(dialogData.Table.Value,lutwidgetData.Table.Value)
        isUICacheDirty=true;
        return;
    end


    for idx=1:length(dialogData.Breakpoints)
        if~isequal(dialogData.Breakpoints(idx).Value,lutwidgetData.Axes(idx).Value)
            isUICacheDirty=true;
            return;
        end
    end
end

function updateLUTWidgetData(h,lutWidgetData)

    lutAxes(1,length(h.DialogData.Breakpoints))=LUTWidget.Axis;
    for idx=1:length(h.DialogData.Breakpoints)
        lutAxes(idx).Value=h.DialogData.Breakpoints(idx).Value;
        lutAxes(idx).Unit=h.DialogData.Breakpoints(idx).Unit;
        lutAxes(idx).FieldName=h.DialogData.Breakpoints(idx).FieldName;



    end
    lutTable=LUTWidget.Table;
    lutTable.Value=h.DialogData.Table.Value;
    lutTable.Unit=h.DialogData.Table.Unit;
    lutTable.FieldName=h.DialogData.Table.FieldName;



    lutWidgetData.setBaselineData(lutTable,lutAxes);
end

function[lutWidget]=drawLUTWidget(h,usingLUTWidget,uniqueTagName)

    lutWidget.Type='webbrowser';
    lutWidget.DisableContextMenu=true;
    lutWidget.Tag='lutwidget_tag';
    lutWidget.ColSpan=[1,5];
    lutWidget.MinimumSize=[200,300];
    rowIdx=getRowIdx(false,1);
    lutWidget.RowSpan=[rowIdx,rowIdx];
    lutWidget.Enabled=usingLUTWidget;
    lutWidget.Visible=usingLUTWidget;
    if usingLUTWidget
        if(~isfield(h.DialogData,'WidgetData')||isempty(h.DialogData.WidgetData))

            lutWidgetData=LUTWidget.Connector;
            lutWidgetData.ValueChangeCallback=@()lutWidgetItemChangedCallback(uniqueTagName);
            h.DialogData.WidgetData=lutWidgetData;
            updateLUTWidgetData(h,h.DialogData.WidgetData);
        end
        lutWidget.Url=h.DialogData.WidgetData.getWidgetUrl();
    end

end


function colHeaders=fillTableColumnHeaders(h,wsObj)

    dtObj=Simulink.data.getDataTypeObjIfFixpt(h.DialogData.Table,wsObj);
    if~isempty(dtObj)
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMinPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMaxPrompt')};
    else
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt')};
    end
    usingLUTWidget=isUsingLUTWidget(h);
    if usingLUTWidget
        firstHeader={DAStudio.message('Simulink:dialog:LookupTableFieldNamePrompt')};
        fieldHeader={};
    else
        firstHeader={DAStudio.message('Simulink:dialog:Value')};
        fieldHeader={DAStudio.message('Simulink:dialog:LookupTableFieldNamePrompt')};
    end
    colHeaders={
    firstHeader{:},...
    DAStudio.message('Simulink:dialog:LookupTableDataTypePrompt'),...
    DAStudio.message('Simulink:dialog:LookupTableDimensionsPrompt'),...
    minMaxHeaders{:},...
    DAStudio.message('Simulink:dialog:LookupTableUnitPrompt'),...
    fieldHeader{:},...
    DAStudio.message('Simulink:dialog:LookupTableDescriptionPrompt')};%#ok<CCAT>

end


function colHeaders=fillBreakpointColumnHeaders(h,wsObj)

    if isequal(h.DialogData.BreakpointsSpecification,'Reference')
        colHeaders={DAStudio.message('Simulink:dialog:LookupTableBpNamePrompt')};
        return;
    end
    bpSpecification=h.DialogData.BreakpointsSpecification;

    includeStoredIntFields=false;
    for i=1:length(h.DialogData.Breakpoints)
        dtObj=Simulink.data.getDataTypeObjIfFixpt(h.DialogData.Breakpoints(i),wsObj);
        if~isempty(dtObj)
            includeStoredIntFields=true;
            break;
        end
    end

    if isequal(includeStoredIntFields,true)
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMinPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMaxPrompt')};
    else
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt')};
    end

    if(isequal(bpSpecification,'Explicit values'))

        usingLUTWidget=isUsingLUTWidget(h);
        if usingLUTWidget
            firstHeader={DAStudio.message('Simulink:dialog:LookupTableFieldNamePrompt')};
            fieldHeader={};
        else
            firstHeader={DAStudio.message('Simulink:dialog:Value')};
            fieldHeader={DAStudio.message('Simulink:dialog:LookupTableFieldNamePrompt')};
        end

        colHeaders={
        firstHeader{:},...
        DAStudio.message('Simulink:dialog:LookupTableDataTypePrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDimensionsPrompt'),...
        minMaxHeaders{:},...
        DAStudio.message('Simulink:dialog:LookupTableUnitPrompt'),...
        fieldHeader{:},...
        DAStudio.message('Simulink:dialog:LookupTableTunableSizeNamePrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDescriptionPrompt')};%#ok<CCAT>
    elseif(isequal(bpSpecification,'Even spacing'))
        colHeaders={
        DAStudio.message('Simulink:dialog:LookupTableEvenspacingBpFirstpointPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableEvenspacingBpSpacingPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataTypePrompt'),...
        minMaxHeaders{:},...
        DAStudio.message('Simulink:dialog:LookupTableUnitPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableFirstPointFieldNamePrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableSpacingFieldNamePrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableTunableSizeNamePrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDescriptionPrompt')};%#ok<CCAT>
    end


    isBpFromALUTObj=true;
    colHeaders=lookuptableddg_hideTunableSizeNameColumn(h,isBpFromALUTObj,colHeaders,...
    DAStudio.message('Simulink:dialog:LookupTableTunableSizeNamePrompt'));

end
