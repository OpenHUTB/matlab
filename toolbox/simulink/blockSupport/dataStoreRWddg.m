function dlgStruct=dataStoreRWddg(source,h)






    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    dsName.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemDstoreName');
    dsName.Type='combobox';
    dsName.Entries=dataStoreRWddg_cb(h.Handle,'getDSMemBlkEntries')';
    dsName.Editable=1;
    dsName.RowSpan=[1,1];
    dsName.ColSpan=[1,2];
    dsName.ObjectProperty='DataStoreName';
    dsName.Tag=dsName.ObjectProperty;

    dsName.MatlabMethod='dataStoreRWddg_cb';
    dsName.MatlabArgs={h.Handle,'sync',source,'%dialog','edit','%tag'};



    dsBlockLbl.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemBlk');
    dsBlockLbl.Type='text';
    dsBlockLbl.RowSpan=[2,2];
    dsBlockLbl.ColSpan=[1,1];
    dsmSrc=dataStoreRWddg_cb(h.Handle,'findMemBlk');
    if~isempty(dsmSrc)
        blockPathArgs=studioHighlight_cb('getBlockPathHandles',gcbp);
        dsBlock.Name=dsmSrc;
        dsBlock.Type='hyperlink';
        dsBlock.MatlabMethod='dataStoreRWddg_cb';
        dsBlock.MatlabArgs={h.Handle,'hilite',dsBlock.Name,blockPathArgs};
        dsBlock.Tag='__Internal_DDG_Tag__hyperlink_datastore';
    else
        dsBlock.Name=DAStudio.message('Simulink:dialog:none_CB');
        dsBlock.Type='text';
        dsBlock.Italic=1;
    end
    dsBlock.RowSpan=[2,2];
    dsBlock.ColSpan=[2,2];

    dsRWBlks.Type='textbrowser';
    dsRWBlks.Text=dataStoreRWddg_cb(h.Handle,'getRWBlksHTML');
    dsRWBlks.RowSpan=[3,3];
    dsRWBlks.ColSpan=[1,2];
    dsRWBlks.Tag='dsRWBlks';

    dsTS.Name=DAStudio.message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');
    dsTS.Type='edit';
    dsTS.RowSpan=[4,4];
    dsTS.ColSpan=[1,2];
    dsTS.ObjectProperty='SampleTime';
    dsTS.Tag=dsTS.ObjectProperty;

    dsTS.MatlabMethod='slDialogUtil';
    dsTS.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    mainTab.Name=DAStudio.message('Simulink:dialog:Parameters');
    mainTab.Items={dsName,dsBlockLbl,dsBlock,dsRWBlks,dsTS};
    mainTab.LayoutGrid=[4,2];
    mainTab.RowStretch=[0,0,1,0];
    mainTab.ColStretch=[0,1];




    if strcmp(h.BlockType,'DataStoreRead')
        diagnosticTab.Name=DAStudio.message('Simulink:blkprm_prompts:ElementSelection');
        outputList.Name=DAStudio.message('Simulink:blkprm_prompts:ElementSelectionDetail1');
        modifyElement.Name=DAStudio.message('Simulink:blkprm_prompts:ElementSelectionDetail2');
    else
        assert(strcmp(h.BlockType,'DataStoreWrite')==1);
        diagnosticTab.Name=DAStudio.message('Simulink:blkprm_prompts:ElementAssignment');
        outputList.Name=DAStudio.message('Simulink:blkprm_prompts:ElementAssignmentDetail1');
        modifyElement.Name=DAStudio.message('Simulink:blkprm_prompts:ElementAssignmentDetail2');
    end

    indexFeatOn=(slfeature('DynamicIndexingDataStore')>0);

    if indexFeatOn
        isDataStoreRead=isequal(get_param(h.Handle,'BlockType'),'DataStoreRead');

        if isempty(source.UserData)||~isfield(source.UserData,'EnableIndex')||...
            isempty(source.UserData.EnableIndex)
            source.UserData.EnableIndex=getEnableIndexing(h.Handle);
        end
        enableIndexVal=source.UserData.EnableIndex;

        enableIndex.Type='checkbox';
        enableIndex.Name=DAStudio.message('Simulink:blkprm_prompts:DSMEnableIndexing');
        enableIndex.NameLocation=2;
        enableIndex.RowSpan=[1,1];
        enableIndex.ColSpan=[5,7];
        enableIndex.Tag='_Enable_Index_';
        enableIndex.Value=isequal(enableIndexVal,true);
        enableIndex.Visible=true;
        enableIndex.Enabled=~source.isHierarchySimulating;
        enableIndex.DialogRefresh=true;
        enableIndex.MatlabMethod='dataStoreRWddg_cb';
        enableIndex.MatlabArgs={h.Handle,'EnableIndexCallback','%dialog',enableIndex.Tag};

        if isempty(source.UserData)||~isfield(source.UserData,'NumDims')||...
            isempty(source.UserData.NumDims)


            [numDimsVal,indexModeVal,tblData]=getDimPropTableData(source,h.Handle);
            source.UserData.NumDims=numDimsVal;
            source.UserData.LastValidNumDims=numDimsVal;
            source.UserData.IndexMode=indexModeVal;
            source.UserData.DimPropTableData=tblData;
        end
        numDimsVal=source.UserData.LastValidNumDims;
        indexModeVal=source.UserData.IndexMode;
        tblData=source.UserData.DimPropTableData;

        numDims.Type='edit';
        numDims.Name=DAStudio.message('Simulink:blkprm_prompts:DSMNumDims');
        numDims.NameLocation=1;
        numDims.Tag='_Number_Of_Dimensions_';
        numDims.Value=num2str(numDimsVal);
        numDims.Enabled=~source.isHierarchySimulating;
        numDims.MatlabMethod='dataStoreRWddg_cb';
        numDims.MatlabArgs={h.Handle,'NumDimsCallback','%dialog',numDims.Tag};

        indexMode.Type='combobox';
        indexMode.Name=DAStudio.message('Simulink:blkprm_prompts:IndexMode');
        indexMode.NameLocation=1;
        indexMode.Tag='_Index_Mode_';
        indexMode.Entries=source.getBlock.getPropAllowedValues('IndexMode');
        indexModeEnumVal=strmatch(indexModeVal,indexMode.Entries,'exact');
        if~isempty(indexModeVal)
            indexMode.Value=indexModeEnumVal-1;
        else
            indexMode.Value=0;
        end
        indexMode.Enabled=~source.isHierarchySimulating;
        indexMode.MatlabMethod='dataStoreRWddg_cb';
        indexMode.MatlabArgs={h.Handle,'IndexModeCallback','%dialog',indexMode.Tag};

        dimPropTable.Tag='_Dimension_Property_';
        dimPropTable.Type='table';
        dimPropTable.Size=[numDimsVal,3];
        dimPropTable.MinimumSize=[400,100];
        dimPropTable.Grid=1;
        dimPropTable.HeaderVisibility=[1,1];
        dimPropTable.ColHeader={DAStudio.message('Simulink:blkprm_prompts:AssignSelectIndexOption'),...
        DAStudio.message('Simulink:blkprm_prompts:AssignSelectIndex'),...
        DAStudio.message('Simulink:blkprm_prompts:AssignSelectOutputSize')};
        dimPropTable.Data=processDimPropTableData(tblData,isDataStoreRead);
        dimPropTable.RowHeaderWidth=floor(log10(max(numDimsVal,1)))+2;
        dimPropTable.ColumnCharacterWidth=[18,8,8];
        dimPropTable.DialogRefresh=1;
        dimPropTable.Editable=1;
        dimPropTable.Enabled=~source.isHierarchySimulating;
        dimPropTable.ValueChangedCallback=@dimsproptableCallback;

        indexPanel.Type='panel';
        indexPanel.Flat=true;
        indexPanel.LayoutGrid=[2,1];
        indexPanel.RowSpan=[2,7];
        indexPanel.ColSpan=[5,7];
        indexPanel.Tag='ElementIndexing';
        indexPanel.Items={numDims,indexMode,dimPropTable};
        indexPanel.Visible=enableIndexVal;
        indexPanel.Enabled=enableIndexVal;
    else
        enableIndexVal=false;
    end

    [treeItems,treeData,unbounded]=dataStoreRWddg_cb(h.Handle,'getTreeItems');
    if~isempty(treeData.Children)
        memoryTree.Name=DAStudio.message('Simulink:blkprm_prompts:SignalsInTheBus');
    else
        memoryTree.Name=DAStudio.message('Simulink:blkprm_prompts:ElementsInTheArray');
    end
    memoryTree.Type='tree';
    memoryTree.Graphical=~enableIndexVal;
    memoryTree.TreeItems=treeItems;
    memoryTree.TreeMultiSelect=~enableIndexVal;
    memoryTree.ExpandTree=enableIndexVal;
    if enableIndexVal
        memoryTreeVal=getTreePathFromDataStoreElements(h.Handle,source.state.DataStoreElements);
        if isempty(memoryTreeVal)
            memoryTreeVal=getTreePathFromDataStoreElements(h.Handle,get_param(h.Handle,'DataStoreName'));
        end
        memoryTree.Value=memoryTreeVal;

    end
    memoryTree.UserData=treeData;
    memoryTree.RowSpan=[1,4]+indexFeatOn;
    memoryTree.ColSpan=[1,3];
    memoryTree.MinimumSize=[250,250];
    memoryTree.Tag='memoryTree';
    if~enableIndexVal
        memoryTree.MatlabMethod='dataStoreRWddg_cb';
        memoryTree.MatlabArgs={h.Handle,'doTreeSelection','%dialog',...
        '%tag','TreeElement','addButton'};
    end


    rowIdx=5+indexFeatOn;

    modifyElement.Tag='ModifySelection';
    modifyElement.Type='text';
    modifyElement.RowSpan=[rowIdx,rowIdx];
    modifyElement.ColSpan=[1,3];
    modifyElement.Visible=~enableIndexVal;

    rowIdx=rowIdx+1;
    selectedElement.Name='';
    selectedElement.Tag='TreeElement';
    selectedElement.Type='edit';
    selectedElement.RowSpan=[rowIdx,rowIdx];
    selectedElement.ColSpan=[1,3];
    selectedElement.Visible=~enableIndexVal;


    entries=dataStoreRWddg_cb(h.Handle,'getListItems',source.state.DataStoreElements);
    outputList.Type='listbox';
    outputList.MultiSelect=1;
    outputList.Entries=entries;
    outputList.UserData=entries;
    outputList.RowSpan=[1,6]+indexFeatOn;
    outputList.ColSpan=[5,7];
    outputList.MinimumSize=[250,250];
    outputList.Tag='outputList';
    outputList.Visible=~enableIndexVal;
    outputList.MatlabMethod='dataStoreRWddg_cb';
    outputList.MatlabArgs={h.Handle,'doListSelection','%dialog','%tag'};
    outputList.ListKeyPressCallback=@listKeyPressCB;
    outputList.ListDoubleClickCallback=@listDoubleClickCB;

    refreshButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Refresh');
    refreshButton.Type='pushbutton';
    refreshButton.RowSpan=[3,3]+indexFeatOn;
    refreshButton.ColSpan=[4,4];
    refreshButton.Enabled=true;
    refreshButton.Tag='refreshButton';
    refreshButton.MatlabMethod='dataStoreRWddg_cb';
    refreshButton.MatlabArgs={h.Handle,'doRefresh','%dialog'};

    addButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Select');
    addButton.Type='pushbutton';
    addButton.RowSpan=[rowIdx,rowIdx];
    addButton.ColSpan=[4,4];
    addButton.Enabled=true;
    addButton.Visible=~enableIndexVal;
    addButton.Tag='addButton';
    addButton.MatlabMethod='dataStoreRWddg_cb';
    addButton.MatlabArgs={h.Handle,'addToOutputList','%dialog','TreeElement','outputList'};


    outputsInvisible.Name='DataStoreElements';
    outputsInvisible.Type='edit';
    outputsInvisible.Value=source.state.DataStoreElements;
    outputsInvisible.Visible=false;
    outputsInvisible.RowSpan=[1,6]+indexFeatOn;
    outputsInvisible.ColSpan=[6,7];
    outputsInvisible.ObjectProperty='DataStoreElements';

    outputsInvisible.Tag='DataStoreElements';

    upButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Up');
    upButton.Type='pushbutton';
    upButton.RowSpan=[1,1]+indexFeatOn;
    upButton.ColSpan=[8,8];
    upButton.Enabled=0;
    upButton.Visible=~enableIndexVal;
    upButton.Tag='upButton';
    upButton.MatlabMethod='dataStoreRWddg_cb';
    upButton.MatlabArgs={h.Handle,'doMove','%dialog',outputList.Tag,'up'};

    downButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Down');
    downButton.Type='pushbutton';
    downButton.RowSpan=[2,2]+indexFeatOn;
    downButton.ColSpan=[8,8];
    downButton.Enabled=0;
    downButton.Visible=~enableIndexVal;
    downButton.Tag='downButton';
    downButton.MatlabMethod='dataStoreRWddg_cb';
    downButton.MatlabArgs={h.Handle,'doMove','%dialog',outputList.Tag,'down'};

    delButton.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_Remove');
    delButton.Type='pushbutton';
    delButton.RowSpan=[3,3]+indexFeatOn;
    delButton.ColSpan=[8,8];
    delButton.Enabled=0;
    delButton.Visible=~enableIndexVal;
    delButton.Tag='removeButton';
    delButton.MatlabMethod='dataStoreRWddg_cb';
    delButton.MatlabArgs={h.Handle,'doRemove','%dialog',outputList.Tag};

    if(indexFeatOn)
        diagnosticTab.Items={memoryTree,modifyElement,outputsInvisible,enableIndex,indexPanel,...
        refreshButton,selectedElement,addButton,...
        outputList,upButton,downButton,delButton};

    else
        diagnosticTab.Items={memoryTree,modifyElement,refreshButton,selectedElement,addButton,...
        outputsInvisible,outputList,upButton,downButton,delButton};
    end

    if indexFeatOn
        diagnosticTab.LayoutGrid=[8,8];
        diagnosticTab.RowStretch=[0,1,1,1,1,0,0,0];
    else
        diagnosticTab.LayoutGrid=[7,8];
        diagnosticTab.RowStretch=[1,1,1,1,0,0,0];
    end
    diagnosticTab.ColStretch=[1,1,1,0,1,1,1,0];




    paramGrp.Name='ParameterTab';
    paramGrp.Type='tab';
    if unbounded
        paramGrp.Tabs={mainTab};
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
    else
        paramGrp.Tabs={mainTab,diagnosticTab};
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
    end
    paramGrp.Source=h;




    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',...
    strrep(h.Name,newline,' '));
    if strcmp(h.BlockType,'DataStoreRead')
        dlgStruct.DialogTag='DataStoreRead';
    else
        assert(strcmp(h.BlockType,'DataStoreWrite')==1);
        dlgStruct.DialogTag='DataStoreWrite';
    end
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.CloseCallback='dataStoreRWddg_cb';
    dlgStruct.CloseArgs={h.Handle,'doClose','%dialog'};
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyCallback='dataStoreRWddg_cb';
    dlgStruct.PreApplyArgs={h.Handle,'doPreApply','%dialog'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end



    function listKeyPressCB(dlg,tag,key)
        if strcmpi(key,'del')
            h=dlg.getSource.getBlock;
            dataStoreRWddg_cb(h.Handle,'doRemove',dlg,tag);
        end



        function listDoubleClickCB(dlg,listWidget,idx)
            entries=dlg.getUserData(listWidget);
            if~isempty(entries)
                dlg.setEnabled('TreeElement',1);
                assert(idx<length(entries));
                dlg.setWidgetValue('TreeElement',entries{idx+1});

                dlg.setWidgetValue('memoryTree','');
            end


            function tblData=processDimPropTableData(tblData,isDataStoreRead)

                numDims=size(tblData,1);
                for row=1:numDims
                    tblData{row,1}.Enabled=true;
                    tblData{row,2}.Enabled=true;
                    tblData{row,3}.Enabled=true;

                    value=tblData{row,1}.Value;

                    if value==0


                        tblData{row,2}.Value='n/a';
                        tblData{row,2}.Enabled=false;


                        tblData{row,3}.Value=DAStudio.message('Simulink:dialog:Selector_OutSizeMsg2');
                        tblData{row,3}.Enabled=false;

                    elseif(value==1||value==3)


                        tblData{row,2}.Enabled=true;


                        if value==1||(value==3&&~isDataStoreRead)
                            tblData{row,3}.Value=DAStudio.message('Simulink:dialog:Selector_OutSizeMsg1');
                            tblData{row,3}.Enabled=false;
                        end

                    elseif(value==2||value==4)


                        tblData{row,2}.Value=DAStudio.message('Simulink:dialog:NDIndexing_IdxStrMsg',row);
                        tblData{row,2}.Enabled=false;


                        if value==2||(value==4&&~isDataStoreRead)
                            tblData{row,3}.Value=DAStudio.message('Simulink:dialog:Selector_OutSizeMsg3',row);
                            tblData{row,3}.Enabled=false;
                        end
                    end
                end


                function dimsproptableCallback(dlg,row,col,value)



                    source=dlg.getDialogSource;
                    userData=source.UserData.DimPropTableData;


                    row=row+1;
                    col=col+1;

                    userData{row,col}.Value=value;

                    source.UserData.DimPropTableData=userData;
                    dlg.refresh;




                    function enableIndex=getEnableIndexing(blkH)

                        enableIndex=false;
                        if slfeature('DynamicIndexingDataStore')>0
                            if strcmp(get_param(blkH,'EnableIndexing'),'on')
                                enableIndex=true;
                            else
                                enableIndex=false;
                            end
                        end

                        function pathStr=getTreePathFromDataStoreElements(blkH,dsElements)

                            [dsElements,~]=strtok(dsElements,'#');
                            [dsElements,~]=strtok(dsElements,'(');
                            dsTreePath=split(dsElements,'.');
                            dsElementTree=get_param(blkH,'DSMemoryLayout');
                            pathStr='';
                            for pathIdx=1:length(dsTreePath)
                                elName=dsTreePath{pathIdx};
                                foundNode=false;
                                for treeIdx=1:length(dsElementTree)
                                    if isequal(elName,dsElementTree(treeIdx).Name)

                                        if~isempty(pathStr)
                                            pathStr=[pathStr,'/'];
                                        end
                                        pathStr=[pathStr,elName];

                                        elDims=dsElementTree(treeIdx).Dimensions;
                                        if~isempty(elDims)
                                            if~isscalar(elDims)
                                                dimStr=mat2str(elDims);
                                                dimStr=strrep(dimStr,' ',',');
                                                pathStr=[pathStr,' ',dimStr];
                                            elseif elDims~=1
                                                dimStr=['[',mat2str(elDims),']'];
                                                pathStr=[pathStr,' ',dimStr];
                                            end
                                        end
                                        foundNode=true;
                                        break;
                                    end
                                end
                                if foundNode&&~isempty(dsElementTree(treeIdx).Children)
                                    dsElementTree=dsElementTree(treeIdx).Children;
                                else
                                    break;
                                end
                            end

                            function[numDimsVal,indexMode,tblData]=getDimPropTableData(source,blkH)

                                numDims=get_param(blkH,'NumberOfDimensions');
                                indexMode=get_param(blkH,'IndexMode');
                                indexOpts=get_param(blkH,'IndexOptionArray');
                                indices=get_param(blkH,'IndexParamArray');
                                outputSizes=get_param(blkH,'OutputSizeArray');

                                numDimsVal=str2num(numDims);
                                tblData=cell(numDimsVal,3);

                                for i=1:numDimsVal


                                    col1.Type='combobox';
                                    col1.Entries=source.getBlock.getPropAllowedValues('IdxOptString');
                                    idxOptEnumVal=strmatch(indexOpts{i},col1.Entries,'exact');
                                    col1.Value=idxOptEnumVal-1;
                                    tblData{i,1}=col1;


                                    col2.Type='edit';
                                    col2.Alignment=6;
                                    col2.Value=indices{i};
                                    tblData{i,2}=col2;


                                    col3.Type='edit';
                                    col3.Alignment=6;
                                    col3.Value=outputSizes{i};
                                    tblData{i,3}=col3;

                                end


