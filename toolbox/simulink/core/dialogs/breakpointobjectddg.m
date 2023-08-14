function dlgstruct=breakpointobjectddg(hProxy,name,varargin)



    if~isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.CoderInfo.HasContext
        hProxy=Simulink.SlidDAProxy(hProxy.getSlidParam);
    end

    if isa(hProxy,'Simulink.SlidDAProxy')
        h=hProxy.getForwardedObject;
        if isa(h,'Simulink.SlidDAProxy')
            h=h.getForwardedObject;
        end
        if isempty(h)
            dlgstruct=[];
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
    if ownedByModel
        slidObj=hProxy.getObject();
        modelRootObj=get_param(slidObj.System.Handle,'Object');
        wsObj=modelRootObj.getWorkspace();
    elseif ownedByDD
        wsObj=varargin{1};
    end

    if isempty(findprop(h,'DialogData'))
        hProp=addprop(h,'DialogData');
        hProp.Transient=true;
        hProp.Hidden=true;
    end
    breakPointTable.Name='';
    breakPointTable.Tag='breakPointTable_tag';
    breakPointTable.Type='table';

    [~,data]=fillBreakpointInfo(hProxy,name,wsObj);

    dataDimensions.Value=length(h.DialogData.Breakpoints);

    breakPointTable.Data=data;
    h.DialogData.bp=data;
    breakPointTable.ColHeader=fillColumnHeaders(h,wsObj);

    breakPointTable.ColumnCharacterWidth=[];

    count=length(breakPointTable.ColHeader);

    for idx=1:count
        if isequal(breakPointTable.Data{idx}.Name,'Value')
            colWidth=20;
        elseif isequal(breakPointTable.Data{idx}.Name,'DataType')
            colWidth=17;
        else
            colWidth=length(breakPointTable.ColHeader{idx});
        end
        breakPointTable.ColumnCharacterWidth=[breakPointTable.ColumnCharacterWidth,...
        colWidth];
    end

    rowIdx=1;

    breakPointsLbl.Name=DAStudio.message('Simulink:dialog:BreakpointsTablePrompt');
    breakPointsLbl.Type='text';
    breakPointsLbl.Tag='BreakpointsLbl';
    breakPointsLbl.RowSpan=[rowIdx,rowIdx];
    breakPointsLbl.ColSpan=[1,1];

    rowIdx=rowIdx+1;


    supportTunableSize.Name=DAStudio.message('Simulink:dialog:LookupTableSupportTunableSizePrompt');
    supportTunableSize.RowSpan=[rowIdx,rowIdx];
    supportTunableSize.ColSpan=[1,1];
    supportTunableSize.Type='checkbox';
    supportTunableSize.DialogRefresh=1;
    supportTunableSize.Tag='supportTunableSize_tag';
    supportTunableSize.Source=h;
    supportTunableSize.ObjectProperty='SupportTunableSize';
    supportTunableSize.MatlabMethod='breakpointddg_cb';
    supportTunableSize.MatlabArgs={'%dialog','%tag','%value'};
    if isempty(h.DialogData)||~isfield(h.DialogData,'SupportTunableSize')||isempty(h.DialogData.SupportTunableSize)
        h.DialogData.SupportTunableSize=h.SupportTunableSize;
    end
    rowIdx=rowIdx+1;

    [rowCount,~]=size(breakPointTable.Data);
    breakPointTable.Size=[rowCount,length(breakPointTable.ColHeader)];
    breakPointTable.Grid=1;
    breakPointTable.HeaderVisibility=[0,1];
    breakPointTable.PreferredSize=[-1,100];
    breakPointTable.RowSpan=[rowIdx,rowIdx];
    breakPointTable.ColSpan=[1,5];
    breakPointTable.DialogRefresh=1;
    breakPointTable.Editable=1;
    breakPointTable.CurrentItemChangedCallback=@bpCurrentItemChangedCallback;
    breakPointTable.ValueChangedCallback=@bptableChangedCallback;
    dlgstruct.Items={breakPointsLbl,supportTunableSize,breakPointTable};



    if isempty(h.DialogData)||~isfield(h.DialogData,'StructTypeInfo')||isempty(h.DialogData.StructTypeInfo)
        h.DialogData.StructTypeInfo=h.StructTypeInfo;
    end

    rowIdx=rowIdx+1;




    if ownedByModel
        argument.Name=DAStudio.message('Simulink:dialog:ArgumentText');
        argument.ObjectProperty='Argument';
        argument.Tag='chkArgument';
        argument.Type='checkbox';
        argument.Source=hProxy;
        argument.Enabled=~hProxy.isReadonlyProperty('Argument');
        argument.Mode=true;
        argument.DialogRefresh=true;
        argument.RowSpan=[rowIdx,rowIdx];
        argument.ColSpan=[1,4];

    end


    rowIdx=1;
    grpNumItems=0;
    grpTypeDef.Name=DAStudio.message('Simulink:dialog:DataTypeGenOptionsPrompt');
    grpTypeDef.Type='group';
    grpTypeDef.Tag='grpTypeDef_tag';
    grpTypeDef.RowSpan=[3,3];
    grpTypeDef.ColSpan=[1,2];
    grpTypeDef.LayoutGrid=[3,2];
    grpTypeDef.Items={};
    grpTypeDef.Source=h.DialogData.StructTypeInfo;

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


    typeName.MatlabMethod='breakpointddg_cb';
    typeName.MatlabArgs={'%dialog','grpTypeDef_tag',typeName.ObjectProperty,'%value'};




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

    dataScope.MatlabMethod='breakpointddg_cb';
    dataScope.MatlabArgs={'%dialog','grpTypeDef_tag',dataScope.ObjectProperty,'%value',dataScope.Entries};




    grpNumItems=grpNumItems+1;
    headerFileLbl.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
    headerFileLbl.Type='text';
    headerFileLbl.Tag='headerFileLbl';
    headerFileLbl.RowSpan=[grpNumItems,grpNumItems];
    headerFileLbl.ColSpan=[1,1];

    headerFile.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
    headerFile.HideName=1;
    headerFile.RowSpan=[grpNumItems,grpNumItems];
    headerFile.ColSpan=[2,2];
    headerFile.Type='edit';
    headerFile.Tag='headerFile_tag';
    headerFile.ObjectProperty='HeaderFileName';
    headerFile.MatlabMethod='breakpointddg_cb';
    headerFile.MatlabArgs={'%dialog','grpTypeDef_tag',headerFile.ObjectProperty,'%value'};

    grpTypeDef.Items={typeNameLbl,typeName,...
    dataScopeLbl,dataScope,...
    headerFileLbl,headerFile};
    grpTypeDef.ColStretch=[1,1];
    grpTypeDef.Enabled=isequal(h.DialogData.SupportTunableSize,1);
    grpTypeDef.Visible=isequal(h.DialogData.SupportTunableSize,1);




    grpDataDef=createCodeGenGroup(h,...
    'Simulink:dialog:LookupTableCoderInfoGroupPrompt',...
    'Simulink:dialog:DataStorageClassToolTip2');
    grpDataDef.RowSpan=[1,1];

    if ownedByModel
        if~hProxy.isValidProperty('StorageClass')
            grpDataDef.Visible=false;
            grpDataDef.Enabled=false;
        end
    end




    if ownedByModel&&slfeature('ModelOwnedDataIM')>0
        grpCodeBtn=createCodeGenBtn(hProxy,...
        'Simulink:dialog:LookupTableCoderInfoGroupPrompt',...
        'Simulink:dialog:ConfigureTextToolTipLookupTable',...
        'Breakpoint');
        if~isempty(grpCodeBtn.Items)
            rowIdx=rowIdx+1;
            grpCodeGen.LayoutGrid=[2,2];
            grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
            grpCodeGen.Type='group';
            grpCodeGen.Tag='grpCodeGen_tag';
            grpCodeGen.RowSpan=[rowIdx,rowIdx];
            grpCodeGen.ColSpan=[1,5];

            grpCodeGen.Items={grpCodeBtn,grpTypeDef};
        else
            grpCodeGen={};
        end
    else
        grpCodeGen.LayoutGrid=[2,2];
        grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        grpCodeGen.Type='group';
        grpCodeGen.Tag='grpCodeGen_tag';
        grpCodeGen.RowSpan=[rowIdx,rowIdx];
        grpCodeGen.ColSpan=[1,5];
        grpCodeGen.Items={grpDataDef,grpTypeDef};
        grpCodeGen.RowStretch=[zeros(1,1),1];
        grpCodeGen.ColStretch=[1,1];
    end





    [grpUserData,tabUserData]=get_userdata_prop_grp(h);

    if~isempty(grpCodeGen)
        grpCodeGen.Name="";
        grpCodeGen.RowSpan=[1,1];
        grpCodeGen.ColStretch=[1,1];


        codeGenerationTab.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        codeGenerationTab.LayoutGrid=[3,2];
        codeGenerationTab.RowStretch=[1,1,1];
        codeGenerationTab.ColStretch=[1,1];
        codeGenerationTab.Tag='TabTwo';
        codeGenerationTab.Items={grpCodeGen};
    end



    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.DialogTag='breakpointobject_tag';




    tabcont.Type='tab';
    tabcont.Tag='TabWhole';

    tab1.Tag='TabOne';
    tab1.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tab1.Items=[dlgstruct.Items];
    if ownedByModel
        tab1.Items=[tab1.Items,argument];
    end


    if(isempty(grpCodeGen)&&isempty(grpUserData.Items))
        tabcont.Tabs={tab1};
    else
        if(isempty(grpUserData.Items))
            tabcont.Tabs={tab1,codeGenerationTab};
        else
            tabcont.Tabs={tab1,codeGenerationTab,tabUserData};
        end
    end

    [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'Breakpoint','TabUserDefinedBP');
    if(~isempty(grpAdditional.Items))
        tabcont.Tabs{end+1}=tabAdditionalProp;
    end

    dlgstruct.Items={tabcont};
    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);
    dlgstruct.LayoutGrid=[1,1];

    dlgstruct.PreApplyCallback='breakpointddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','preapply'};
    dlgstruct.PostApplyCallback='breakpointddg_cb';
    dlgstruct.PostApplyArgs={'%dialog','postapply'};
    dlgstruct.PreRevertCallback='breakpointddg_cb';
    dlgstruct.PreRevertArgs={'%dialog','prerevert'};
    dlgstruct.CloseCallback='breakpointddg_cb';
    dlgstruct.CloseArgs={'%dialog','close'};


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_breakpoint'};

    h.DialogData.bpValueDirty=false;
    if isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.isReadonlyProperty('Value')
        for i=1:numel(dlgstruct.Items)
            dlgstruct.Items{i}.Enabled=false;
        end
    end
end

function colHeaders=fillColumnHeaders(h,wsObj)


    dtObj=Simulink.data.getDataTypeObjIfFixpt(h.DialogData.Breakpoints,wsObj);
    if~isempty(dtObj)
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMinPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataStoredIntMaxPrompt')};
    else
        minMaxHeaders={DAStudio.message('Simulink:dialog:LookupTableDataMinimumPrompt'),...
        DAStudio.message('Simulink:dialog:LookupTableDataMaximumPrompt')};
    end
    colHeaders={DAStudio.message('Simulink:dialog:Value'),...
    DAStudio.message('Simulink:dialog:LookupTableDataTypePrompt'),...
    DAStudio.message('Simulink:dialog:LookupTableDimensionsPrompt'),...
    minMaxHeaders{:},...
    DAStudio.message('Simulink:dialog:LookupTableUnitPrompt'),...
    DAStudio.message('Simulink:dialog:LookupTableFieldNamePrompt'),...
    DAStudio.message('Simulink:dialog:LookupTableTunableSizeNamePrompt'),...
    DAStudio.message('Simulink:dialog:LookupTableDescriptionPrompt')};


    isBpFromALUTObj=false;
    colHeaders=lookuptableddg_hideTunableSizeNameColumn(h,isBpFromALUTObj,colHeaders,...
    DAStudio.message('Simulink:dialog:LookupTableTunableSizeNamePrompt'));

end


function bpCurrentItemChangedCallback(dlg,~,~)
    dlg.enableApplyButton(true);
end


function bptableChangedCallback(dlg,row,col,value)
    source=dlg.getSource;
    obj=source.getForwardedObject;
    wsObj=[];

    if isa(obj,'Simulink.SlidDAProxy')
        slidObj=obj.getObject();
        modelRootObj=get_param(slidObj.System.Handle,'Object');
        obj=obj.getForwardedObject;
        wsObj=modelRootObj.getWorkspace();
    end

    if isa(source,'Simulink.dd.EntryDDGSource')
        dd=Simulink.data.dictionary.open(source.m_originalDataSource);
        wsObj=dd.getSection(source.m_scope);
    end

    if~isempty(obj)
        source=obj;
    end
    data=source.DialogData.bp;
    bps=source.DialogData.Breakpoints;

    if(row+1)>length(bps)
        bp=Simulink.lookuptable.Breakpoints;
    else
        bp=bps(row+1);
    end

    if isequal(data{row+1,col+1}.Name,'DataType')&&...
        strcmp(value,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))

        slprivate('slGetUserDataTypesFromWSDD',...
        source,[],[],true);
        dlg.setTableItemValue('breakPointTable_tag',row,col,data{row+1,col+1}.Value);
        dlg.refresh();
    elseif Simulink.data.isStoredIntProperty(data{row+1,col+1}.Name)
        realWorldVal=Simulink.data.convertStoredIntegerToRealWorldValue(bps,value,wsObj);
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

        if isequal(data{row+1,col+1}.Name,'Value')
            source.DialogData.bpValueDirty=true;
            [~,datacols]=size(data);
            for colidx=1:datacols
                if isequal(data{row+1,colidx}.Name,'Dimensions')
                    newDim=getPropValue(bp,'Dimensions');
                    dlg.setTableItemValue('breakPointTable_tag',row,colidx-1,newDim);
                    break;
                end
            end
        elseif(isequal(data{row+1,col+1}.Name,'DataType')||...
            isequal(data{row+1,col+1}.Name,'Min')||...
            isequal(data{row+1,col+1}.Name,'Max'))

            dlg.refresh();
        end

        data{row+1,col+1}.Value=value;
        source.DialogData.bp=data;
        bps(row+1)=bp;
        source.DialogData.Breakpoints=bps;
    end
end


function[cols,tableData]=fillBreakpointInfo(hProxy,name,wsObj)

    if isa(hProxy,'Simulink.SlidDAProxy')
        h=hProxy.getForwardedObject;
        if isa(h,'Simulink.SlidDAProxy')
            h=h.getForwardedObject;
        end
    else
        h=hProxy;
    end

    if isempty(h.Breakpoints)
        errordlg(DAStudio.message('Simulink:Data:LUT_Invalid_LUTObject_EmptyBreakpointVector',name),name,'modal');
    end

    cols=getPossibleProperties(h.Breakpoints(1))';
    tableData={};
    rowidx=1;
    if isempty(h.DialogData)||~isfield(h.DialogData,'Breakpoints')||isempty(h.DialogData.Breakpoints)
        h.DialogData.Breakpoints=h.Breakpoints;
    end
    storedIntColRequired=false;
    dtObj=Simulink.data.getDataTypeObjIfFixpt(h.DialogData.Breakpoints);
    if~isempty(dtObj)
        storedIntColRequired=true;
    end
    assert(isequal(length(h.Breakpoints),1));
    isBpFromALUTObj=false;
    supportEnumType=true;
    tableData=[tableData;lookuptableddg_addData(hProxy,h.DialogData.Breakpoints,rowidx,isBpFromALUTObj,supportEnumType,wsObj,storedIntColRequired)];
end
