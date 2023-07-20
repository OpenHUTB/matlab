function dlgstruct=dictionaryrootddg(hObj)















    useVariantAsProperty=false;
    altDisp=false;
    if~useVariantAsProperty&&(slfeature('SLDataDictionaryVariants')>0)&&~isempty(hObj.getPropValue('Variant'))
        altDisp=true;
    end

    DictRootDesc.Type='textbrowser';
    DictRootDesc.Text=l_DictRootInfo(hObj,useVariantAsProperty);
    DictRootDesc.Tag='DictRootDesc';
    if altDisp
        DictRootDesc.RowSpan=[1,1];
        DictRootDesc.ColSpan=[1,4];
    end

    if altDisp
        variantLabel.Type='text';
        variantLabel.Name='Variant condition:';
        variantLabel.RowSpan=[2,2];
        variantLabel.ColSpan=[1,1];

        variantField.Tag='variantEdit';
        variantField.Type='edit';


        variantField.RowSpan=[2,2];
        variantField.ColSpan=[2,4];
        variantField.Enabled=true;
        variantField.Visible=true;
        variantField.Value=hObj.getPropValue('Variant');

        variantSaveBtn.Name=DAStudio.message('Simulink:editor:DialogApply');
        variantSaveBtn.Tag='variantSaveBtn';
        variantSaveBtn.Type='pushbutton';
        variantSaveBtn.Visible=true;
        variantSaveBtn.RowSpan=[3,3];
        variantSaveBtn.ColSpan=[4,4];
        variantSaveBtn.MatlabMethod='dictionaryrootddg_cb';
        variantSaveBtn.MatlabArgs={'%dialog','%tag'};

        variantCancelBtn.Name='Revert';
        variantCancelBtn.Tag='variantCancelBtn';
        variantCancelBtn.Type='pushbutton';
        variantCancelBtn.Visible=true;
        variantCancelBtn.RowSpan=[3,3];
        variantCancelBtn.ColSpan=[3,3];
        variantCancelBtn.MatlabMethod='dictionaryrootddg_cb';
        variantCancelBtn.MatlabArgs={'%dialog','%tag'};
    end

    if slfeature('CalibrationWorkflowInDD')==2
        valueSourceName.Tag='valueSourceName';
        valueSourceName.Type='edit';
        valueSourceName.Name='Value source:';
        valueSourceName.Value=hObj.getConnection().ValueSource;
        valueSourceName.DialogRefresh=1;
        valueSourceName.RowSpan=[1,1];
        valueSourceName.ColSpan=[1,3];
        valueSourceName.Enabled=true;
        valueSourceName.Visible=true;
        valueSourceName.Graphical=true;
        valueSourceName.MatlabMethod='dictionaryrootddg_cb';
        valueSourceName.MatlabArgs={'%dialog','%tag'};

        valSrcBrowseBtn.Name='Browse ...';
        valSrcBrowseBtn.Type='pushbutton';
        valSrcBrowseBtn.Tag='ValueSourceBrowseBtn';
        valSrcBrowseBtn.RowSpan=[1,1];
        valSrcBrowseBtn.ColSpan=[4,4];
        valSrcBrowseBtn.MatlabMethod='dictionaryrootddg_cb';
        valSrcBrowseBtn.MatlabArgs={'%dialog','%tag'};










        valSrcNote.Name='Note: The value source can only override symbols defined within this (fuelsysDD.sldd) dictionary, not in any referenced dictionaries.';
        valSrcNote.Type='text';
        valSrcNote.WordWrap=true;
        valSrcNote.Tag='RefDictionaryHasAccessToBWS';
        valSrcNote.Visible=false;
        valSrcNote.RowSpan=[2,2];
        valSrcNote.ColSpan=[1,4];

        valueSourceGrp.Name="";
        valueSourceGrp.LayoutGrid=[2,4];
        valueSourceGrp.Type="group";
        valueSourceGrp.Flat=0;
        valueSourceGrp.Tag="DictValueSourceGrp";
        valueSourceGrp.Items={valueSourceName,valSrcBrowseBtn,valSrcNote};
    end


    DictRefTree.Type='tree';
    DictRefTree.Tag='DictRefTree';
    DictRefTree.Name=hObj.getNodeName;
    treeItems={};%#ok<NASGU>
    treeMap=containers.Map();
    i_getDDInfo([]);

    if(slfeature('HierarchicalDependencyTree')>0)
        [treeItems,treeMap]=i_BuildHierarchicalTree(hObj,hObj.getFileSpec,'',treeMap,{},true);
    else
        [treeItems,treeMap]=i_BuildFlatTree(hObj,hObj.getFileSpec,treeMap);
    end

    DictRefTree.UserData=treeMap;
    DictRefTree.TreeItems=treeItems;
    DictRefTree.TreeMultiSelect=true;
    DictRefTree.RowSpan=[3,20];
    DictRefTree.ColSpan=[1,3];
    DictRefTree.Graphical=true;
    DictRefTree.MatlabMethod='dictionaryrootddg_cb';
    DictRefTree.MatlabArgs={'%dialog','%tag'};

    refInfoLabel.Type='text';
    refInfoLabel.Name=DAStudio.message('Simulink:dialog:DataDictRefDesc');
    refInfoLabel.RowSpan=[1,2];
    refInfoLabel.ColSpan=[1,4];

    rowIndex=3;

    addBtn.Name=DAStudio.message('Simulink:dialog:DataDictRefTableAddBtn');
    addBtn.Type='pushbutton';
    addBtn.Tag='AddBtn';
    addBtn.MatlabMethod='dictionaryrootddg_cb';
    addBtn.MatlabArgs={'%dialog','%tag'};
    addBtn.RowSpan=[rowIndex,rowIndex];
    addBtn.ColSpan=[4,4];

    rowIndex=rowIndex+1;

    depViewBtn.Name=DAStudio.message('Simulink:dialog:DataDictRefTableDepViewBtn');
    depViewBtn.Type='pushbutton';
    depViewBtn.Tag='DepViewBtn';
    depViewBtn.MatlabMethod='dictionaryrootddg_cb';
    depViewBtn.MatlabArgs={'%dialog','%tag',hObj.getFileSpec};
    depViewBtn.RowSpan=[rowIndex,rowIndex];
    depViewBtn.ColSpan=[4,4];


    if isempty(treeItems)
        depViewBtn.Enabled=false;
    else
        depViewBtn.Enabled=true;
    end


    if(slfeature('HierarchicalDependencyTree')>0)
        depViewBtn.Visible=false;
    else
        depViewBtn.Visible=true;
        rowIndex=rowIndex+1;
    end

    newVariantBtn.Name=DAStudio.message('SLDD:sldd:CreateVariantDD');
    newVariantBtn.Type='pushbutton';
    newVariantBtn.Tag='NewVariantBtn';
    newVariantBtn.MatlabMethod='dictionaryrootddg_cb';
    newVariantBtn.MatlabArgs={'%dialog','%tag'};
    newVariantBtn.RowSpan=[1,1];
    newVariantBtn.ColSpan=[2,2];

    removeBtn.Name=DAStudio.message('Simulink:dialog:DataDictRefTableRemoveBtn');
    removeBtn.Type='pushbutton';
    removeBtn.Tag='RemoveBtn';
    removeBtn.MatlabMethod='dictionaryrootddg_cb';
    removeBtn.MatlabArgs={'%dialog','%tag'};
    removeBtn.RowSpan=[rowIndex,rowIndex];
    removeBtn.ColSpan=[4,4];
    removeBtn.Enabled=false;

    rowIndex=rowIndex+1;

    browseBtn.Name=DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonName');
    browseBtn.Type='pushbutton';
    browseBtn.Tag='BrowseBtn';
    browseBtn.MatlabMethod='dictionaryrootddg_cb';
    browseBtn.MatlabArgs={'%dialog','%tag'};
    browseBtn.RowSpan=[rowIndex,rowIndex];
    browseBtn.ColSpan=[4,4];
    browseBtn.Enabled=false;
    browseBtn.Visible=false;

    openBtn.Name=DAStudio.message('Simulink:dialog:DataDictRefTableOpenBtn');
    openBtn.Type='pushbutton';
    openBtn.Tag='OpenBtn';
    openBtn.MatlabMethod='dictionaryrootddg_cb';
    openBtn.MatlabArgs={'%dialog','%tag'};
    openBtn.RowSpan=[rowIndex,rowIndex];
    openBtn.ColSpan=[4,4];
    openBtn.Enabled=false;


    newRefFile.Name='';
    newRefFile.Type='text';
    newRefFile.Visible=false;
    newRefFile.Enabled=false;
    newRefFile.Tag='DictNewRefName';
    newRefFile.Value='';
    newRefFile.Graphical=true;

    if(slfeature('SLDDBroker')>0)
        refgrp.Name=DAStudio.message('Simulink:dialog:DataDictAllRefGrpName');
    else
        refgrp.Name=DAStudio.message('Simulink:dialog:DataDictRefGrpName');
    end

    refgrp.LayoutGrid=[20,4];
    refgrp.Type='group';
    refgrp.Flat=0;
    if slfeature('SLDataDictionaryVariants')
        if(slfeature('SLDDBroker')>0)
            refgrp.Items={refInfoLabel,DictRefTree,depViewBtn,addBtn,newVariantBtn,removeBtn,browseBtn,openBtn,newRefFile};
        else
            refgrp.Items={DictRefTree,depViewBtn,addBtn,newVariantBtn,removeBtn,browseBtn,openBtn,newRefFile};
        end
    else
        if(slfeature('SLDDBroker')>0)
            refgrp.Items={refInfoLabel,DictRefTree,depViewBtn,addBtn,removeBtn,browseBtn,openBtn,newRefFile};
        else
            refgrp.Items={DictRefTree,depViewBtn,addBtn,removeBtn,browseBtn,openBtn,newRefFile};
        end
    end

    if slfeature('CalibrationWorkflowInDD')==2
        valueSourceName.Tag='valueSourceName';
        valueSourceName.Type='edit';
        valueSourceName.Name='Value source:';
        valueSourceName.Value=hObj.getConnection().ValueSource;
        valueSourceName.DialogRefresh=1;
        valueSourceName.RowSpan=[1,1];
        valueSourceName.ColSpan=[1,3];
        valueSourceName.Enabled=true;
        valueSourceName.Visible=true;
        valueSourceName.Graphical=true;
        valueSourceName.MatlabMethod='dictionaryrootddg_cb';
        valueSourceName.MatlabArgs={'%dialog','%tag'};

        valSrcBrowseBtn.Name='Browse ...';
        valSrcBrowseBtn.Type='pushbutton';
        valSrcBrowseBtn.Tag='ValueSourceBrowseBtn';
        valSrcBrowseBtn.RowSpan=[1,1];
        valSrcBrowseBtn.ColSpan=[4,4];
        valSrcBrowseBtn.MatlabMethod='dictionaryrootddg_cb';
        valSrcBrowseBtn.MatlabArgs={'%dialog','%tag'};

        valSrcRefreshBtn.Name='Refresh';
        valSrcRefreshBtn.Type='pushbutton';
        valSrcRefreshBtn.Tag='ValueSourceRefreshBtn';
        valSrcRefreshBtn.RowSpan=[2,2];
        valSrcRefreshBtn.ColSpan=[4,4];
        valSrcRefreshBtn.Visible=false;
        valSrcRefreshBtn.MatlabMethod='dictionaryrootddg_cb';
        valSrcRefreshBtn.MatlabArgs={'%dialog','%tag'};

        valueSourceGrp.Name="";
        valueSourceGrp.LayoutGrid=[2,4];
        valueSourceGrp.Type="group";
        valueSourceGrp.Flat=0;
        valueSourceGrp.Tag="DictValueSourceGrp";
        valueSourceGrp.Items={valueSourceName,valSrcBrowseBtn,valSrcRefreshBtn};
    end

    refgrp.Tag='DictRefGrp';
    if slfeature('SLDataDictionaryVariants')&&~isempty(hObj.getPropValue('Variant'))
        refgrp.Visible=false;
    end

    isInterfaceDictionary=sl.interface.dict.api.isInterfaceDictionary(hObj.getFileSpec());
    if isInterfaceDictionary
        dictionaryType=DAStudio.message('interface_dictionary:common:GuiTitle');
    else
        dictionaryType=DAStudio.message('Simulink:dialog:DataDictDialogTitle');
    end
    dlgstruct.DialogTitle=[dictionaryType,': ',hObj.getNodeName];

    if slfeature('EnableDictionaryToLookIntoBWS')
        lastRow=1;
        accessBWS.Tag='AccessBaseWorkspace';
        accessBWS.Type='checkbox';
        accessBWS.Name=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccessForDD');
        accessBWS.ToolTip=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccessForDDTooltip');
        accessBWS.Source=hObj;
        accessBWS.ObjectProperty='AccessBaseWorkspace';
        accessBWS.Mode=1;
        accessBWS.RowSpan=[lastRow,lastRow];
        accessBWS.ColSpan=[1,1];
        accessBWS.Visible=true;
        accessBWS.DialogRefresh=true;
        accessBWS.MatlabMethod='dictionaryrootddg_cb';
        accessBWS.MatlabArgs={'%dialog','%tag'};

        showRefDictHasAccessNote=hObj.RefDictionariesAccessBaseWorkspace&&...
        ~hObj.AccessBaseWorkspace;
        if showRefDictHasAccessNote
            lastRow=lastRow+1;
            refDictionaryAccessBWS.Name=DAStudio.message('SLDD:sldd:ReferencedDictionaryAccessToBWS');
            refDictionaryAccessBWS.Type='text';
            refDictionaryAccessBWS.WordWrap=true;
            refDictionaryAccessBWS.Tag='RefDictionaryHasAccessToBWS';
            refDictionaryAccessBWS.RowSpan=[lastRow,lastRow];
            refDictionaryAccessBWS.ColSpan=[1,1];
        end

        accessBWSGrp.Name="";
        accessBWSGrp.LayoutGrid=[lastRow,1];
        accessBWSGrp.Type="group";
        accessBWSGrp.Flat=0;
        accessBWSGrp.Tag="DictAccessBaseWorkspaceGrp";

        accessBWSGrp.Items={accessBWS};
        if showRefDictHasAccessNote
            accessBWSGrp.Items=[accessBWSGrp.Items,{refDictionaryAccessBWS}];
        end
    end
    openItfDictBtn.Tag='openItfDictBtn';
    openItfDictBtn.Type='pushbutton';
    openItfDictBtn.Name=DAStudio.message('interface_dictionary:common:LaunchStudioApp');
    openItfDictBtn.RowSpan=[2,2];
    openItfDictBtn.ColSpan=[1,1];
    openItfDictBtn.MatlabMethod='sl.interface.dictionaryApp.StudioApp.open';
    openItfDictBtn.MatlabArgs={hObj.getFileSpec};

    openItfDictGrp.Name="";
    openItfDictGrp.LayoutGrid=[1,1];
    openItfDictGrp.Type="group";
    openItfDictGrp.Flat=0;
    openItfDictGrp.Tag="openItfDictGrp";
    openItfDictGrp.Items={openItfDictBtn};

    spacer.Name="";
    spacer.Type="group";
    spacer.Tag="spacer";
    spacer.Visible=false;
    spacer.LayoutGrid=[1,1];
    spacer.Items={};

    if altDisp
        dlgstruct.Items={DictRootDesc,variantLabel,variantField,variantCancelBtn,variantSaveBtn,refgrp};
        dlgstruct.LayoutGrid=[4,4];
        dlgstruct.RowStretch=[1,1,1,2];
    else
        if isInterfaceDictionary
            dlgstruct.Items={DictRootDesc,openItfDictGrp,spacer};
            dlgstruct.LayoutGrid=[3,1];
            dlgstruct.RowStretch=[0,0,3];
        elseif slfeature('EnableDictionaryToLookIntoBWS')
            dlgstruct.Items={DictRootDesc,refgrp,accessBWSGrp};
            dlgstruct.LayoutGrid=[3,1];
            dlgstruct.RowStretch=[1,2,0];
        else
            dlgstruct.Items={DictRootDesc,refgrp};
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.RowStretch=[1,2];
        end

        if slfeature('CalibrationWorkflowInDD')==2
            dlgstruct.Items={DictRootDesc,valueSourceGrp,refgrp,accessBWSGrp};
            dlgstruct.LayoutGrid=[4,1];
            dlgstruct.RowStretch=[1,0,2,0];
        end
        dlgstruct.EmbeddedButtonSet={'Help'};
    end
    dlgstruct.StandaloneButtonSet={'Ok','Help'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
end


function html=l_DictRootInfo(h,useVariantAsProperty)

    if isequal(h.isDirty,'yes')
        isModifiedStr=['<font color=''red''>',DAStudio.message('Simulink:dialog:DataDictHTMLTextIsModifiedYes'),'</font>'...
        ,' (','<a href="matlab:slprivate(''slddShowChanges'', ''','%s',''');">',...
        DAStudio.message('SLDD:sldd:ContextShowChanges'),'</a>',')'];
    else
        isModifiedStr=DAStudio.message('Simulink:dialog:DataDictHTMLTextIsModifiedNo');
    end

    str=['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
    '<tr><td>',...
    '<b><font size=+2>',DAStudio.message('Simulink:dialog:DataDictHTMLTextInfoFor'),' %s</b></font>',...
    '<table>',...
    '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextSourceFile'),'</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextCreated'),'</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextLastModified'),'</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextLastSaved'),'</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextIsModified'),'</b></td><td>',isModifiedStr,'</td></tr>'];

    if useVariantAsProperty&&slfeature('SLDataDictionaryVariants')&&~isempty(h.getPropValue('Variant'))
        variantStr=['<tr><td align="right"><b>','Variant Condition:','</b></td><td>%s',...
        ' (','<a href="matlab:slprivate(''editVariant'', ''','%s',''');">Edit...','</a>',')</td></tr>'];
        variantCondition=sprintf(variantStr,h.getPropValue('Variant'),h.getFileSpec);
        str=[str,variantCondition];
    end

    str=[str,...
    '</table>',...
    '</td></tr>',...
    '</table>',...
    ];

    [createdDateTime,lastModDateTime,lastSaveDateTime]=h.getStatus();

    if isequal(h.isDirty,'yes')
        html=sprintf(str,h.getNodeName,h.getFileSpec,createdDateTime,lastModDateTime,lastSaveDateTime,h.getFileSpec);
    else
        html=sprintf(str,h.getNodeName,h.getFileSpec,createdDateTime,lastModDateTime,lastSaveDateTime);
    end
end

function[treeItems,treeMap]=i_BuildHierarchicalTree(h,node,hierarchyString,treeMap,branchlist,useRootConnection)




    [~,branchName,branchExt]=fileparts(node);
    if~isequal(branchExt,'.sldd')||slfeature('SLDDBroker')>0
        branchName=[branchName,branchExt];
    end
    branchlist{length(branchlist)+1}=branchName;

    list={};
    try
        if useRootConnection
            [~,~,list,~,~,supportedExt]=i_getDDInfo(h.getConnection());
        else
            [~,~,list,~,~,supportedExt]=i_getDDInfo(node);
        end

        brokerRefs=i_GetBrokerReferences(node);
        if~isempty(brokerRefs)
            list(end+1:end+length(brokerRefs))=brokerRefs;
        end
    catch
    end

    treeItems={};
    for i=1:length(list)
        [~,fileName,fileExt]=fileparts(list{i});
        exploreSubTree=true;
        if~isequal(fileExt,'.sldd')
            exploreSubTree=false;
            if(any(strcmp(fileExt,supportedExt)))
                refName=[fileName,fileExt];
            else
                refName=[fileName,fileExt,' ',DAStudio.message('slid:messages:UnsupportedExternalSource')];
            end
        else
            if(slfeature('SLDDBroker')>0)
                refName=[fileName,fileExt];
            else
                refName=fileName;
            end
        end

        dirty='';
        count=-1;
        variantCondition='';
        foundReference=false;
        try
            if(slfeature('SLDDBroker')>0)&&...
                ~isequal(list{i},'.sldd')&&...
                ((exist(list{i},'file')==4)||(exist(list{i},'file')==2))
                foundReference=true;
            else
                [count,dirty,~,exploreSubTree,variantCondition,~]=i_getDDInfo(list{i});
                foundReference=exploreSubTree;
            end
        catch
            exploreSubTree=false;
        end


        if(slfeature('SLDDBroker')>0)
            if foundReference
                nodename=refName;
                if~isempty(variantCondition)
                    nodename=[nodename,'  [',variantCondition,']'];%#ok<AGROW>
                end
            else
                nodename=[refName,DAStudio.message('SLDD:sldd:MissingRefDict')];
            end
        else
            if isequal(count,-1)
                nodename=[refName,dirty,' ',DAStudio.message('SLDD:sldd:MissingRefDict')];
            else
                nodename=[refName,dirty,' (',num2str(count),')'];
                if~isempty(variantCondition)
                    nodename=[nodename,'  [',variantCondition,']'];%#ok<AGROW>
                end
            end
        end

        if isempty(hierarchyString)
            treeStr=nodename;
        else
            treeStr=[hierarchyString,'/',nodename];
        end

        treeMap(treeStr)={list{i},isempty(hierarchyString)};

        treeItems{end+1}=nodename;%#ok<AGROW>

        if ismember(refName,branchlist)
            exploreSubTree=false;
        end

        if exploreSubTree
            [subtreeItems,treeMap]=i_BuildHierarchicalTree(h,list{i},treeStr,treeMap,branchlist,false);
            if~isempty(subtreeItems)
                treeItems{end+1}=subtreeItems;%#ok<AGROW>
            end
        end
    end
end

function[treeItems,treeMap]=i_BuildFlatTree(h,node,treeMap)




    directRefs={};
    try

        [~,~,directRefs,~,~,supportedExt]=i_getDDInfo(h.getConnection());

        brokerRefs=i_GetBrokerReferences(node);
        if~isempty(brokerRefs)
            directRefs(end+1:end+length(brokerRefs))=brokerRefs;
        end
    catch
    end

    treeItems={};
    for i=1:length(directRefs)


        [parentNodeName,fileExt]=i_BuildFlatTreeHelper(directRefs{i},supportedExt);
        treeMap(parentNodeName)={directRefs{i},true};
        treeItems{end+1}=parentNodeName;%#ok<AGROW>

        if isequal(fileExt,'.sldd')

            indirectRefs={};

            try
                directRefDD=Simulink.dd.open(directRefs{i},'SubdictionaryErrorAction','warn');
                indirectRefs=directRefDD.DependencyClosure;

                indirectRefs(ismember(indirectRefs,directRefs{i}))=[];
                close(directRefDD);

                brokerRefs=i_GetBrokerReferences(directRefs{i});
                if~isempty(brokerRefs)
                    indirectRefs(end+1:end+length(brokerRefs))=brokerRefs;
                end
            catch
            end

            if~isempty(indirectRefs)
                subtreeItems={};
                for j=1:length(indirectRefs)


                    [childNodeName,~]=i_BuildFlatTreeHelper(indirectRefs{j},supportedExt);
                    fullName=[parentNodeName,'/',childNodeName];
                    treeMap(fullName)={indirectRefs{j},false};
                    subtreeItems{end+1}=childNodeName;%#ok<AGROW>
                end
                treeItems{end+1}=subtreeItems;%#ok<AGROW>
            end
        end
    end
end

function[nodename,fileExt]=i_BuildFlatTreeHelper(dataSourceFullPath,supportedExt)


    [~,fileName,fileExt]=fileparts(dataSourceFullPath);

    if~isequal(fileExt,'.sldd')
        if(any(strcmp(fileExt,supportedExt)))
            refName=[fileName,fileExt];
        else
            refName=[fileName,fileExt,' ',DAStudio.message('slid:messages:UnsupportedExternalSource')];
        end
    else
        if(slfeature('SLDDBroker')>0)
            refName=[fileName,fileExt];
        else
            refName=fileName;
        end
    end

    dirty='';
    count=-1;
    variantCondition='';
    foundReference=false;
    try
        if(slfeature('SLDDBroker')>0)&&...
            ~isequal(dataSourceFullPath,'.sldd')&&...
            ((exist(dataSourceFullPath,'file')==4)||(exist(dataSourceFullPath,'file')==2))
            foundReference=true;
        else
            [count,dirty,~,exploreSubTree,variantCondition,~]=i_getDDInfo(dataSourceFullPath);
            foundReference=exploreSubTree;
        end
    catch
    end

    if(slfeature('SLDDBroker')>0)
        if foundReference
            nodename=refName;
            if~isempty(variantCondition)
                nodename=[nodename,'  [',variantCondition,']'];
            end
        else
            nodename=[refName,DAStudio.message('SLDD:sldd:MissingRefDict')];
        end
    else
        if isequal(count,-1)
            nodename=[refName,dirty,' ',DAStudio.message('SLDD:sldd:MissingRefDict')];
        else
            nodename=[refName,dirty,' (',num2str(count),')'];
            if~isempty(variantCondition)
                nodename=[nodename,'  [',variantCondition,']'];
            end
        end
    end
end

function brokerRefs=i_GetBrokerReferences(ddFullPath)



    brokerRefs={};

    if(slfeature('SLDDBroker')>0)
        slidRefList=Simulink.internal.slid.DictionaryInterface.getReferencesURLs(ddFullPath);

        [~,~,exts]=cellfun(@(x)fileparts(x),slidRefList,'UniformOutput',false);
        brokerIndices=cellfun(@(x)any(strcmp(x,'.sldd')),exts);
        brokerRefs=slidRefList(~brokerIndices);
    end
end

function tableData=getValueVariantsTableData(hObj)
    tableData={};
    ddConn=hObj.getConnection();
    valueSourceList=ddConn.ValueSourceDependencies;
    for i=1:length(valueSourceList)
        valueSourceName=valueSourceList{i};
        valueSourceCondition=ddConn.getValueSourceCondition(valueSourceName);
        tableData(i,:)={valueSourceName,valueSourceCondition};
    end
end

function i_VariantsTableSelectionChanged(dialogH,row,~)
    disp('Table selection changed');
end

function i_VariantsTableValueChanged(dialogH,row,col,newVal)
    source=dialogH.getSource;
    ddConn=source.getConnection();
    valueSourceList=ddConn.ValueSourceDependencies;
    valueSourceName=valueSourceList{row+1};
    ddConn.setValueSourceCondition(valueSourceName,newVal);
end

function[count,dirty,dependencies,isOpen,variantCondition,supportedExt]...
    =i_getDDInfo(ddObj)
    persistent ddCache;

    supportedExt={};
    if isempty(ddObj)
        ddCache=containers.Map;
    else
        if isa(ddObj,'Simulink.dd.Connection')
            ddConn=ddObj;
            ddName=ddObj.filespec;
        else
            ddConn=[];
            ddName=ddObj;
        end

        if ddCache.isKey(ddName)
            entry=ddCache(ddName);
            count=entry{1};
            dirty=entry{2};
            dependencies=entry{3};
            isOpen=entry{4};
            variantCondition=entry{5};
            supportedExt=entry{6};
        else
            if isempty(ddConn)
                closeDD=true;
                ddConn=Simulink.dd.open(ddName,'SubdictionaryErrorAction','warn');
            else
                closeDD=false;
            end
            if ddConn.isOpen()
                isOpen=true;
                supportedExt=ddConn.getBroker.getSupportedExtensions();
                if ddConn.hasUnsavedChanges
                    dirty='*';
                else
                    dirty='';
                end

                count=ddConn.numEntries;
                if slfeature('SLDataDictionaryVariants')
                    variantCondition=ddConn.getVariant();
                else
                    variantCondition='';
                end
                dependencies=ddConn.Dependencies;
                ddCache(ddName)={count,dirty,dependencies,...
                isOpen,variantCondition,supportedExt};
                if closeDD
                    ddConn.close();
                end
            end
        end
    end
end



