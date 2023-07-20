function dlgstruct=busddg(h,name,isSlidStructureType)






















































    rowIdx=0;



    mlock;






    if isSlidStructureType
        h=getBusStructForSlidStructureType(h);
    end

    editorbtn.Name=DAStudio.message('Simulink:dialog:BusEditorbtnName');
    editorbtn.Type='pushbutton';
    editorbtn.MatlabMethod='buseditor';


    cachedDataSource=slprivate('slUpdateDataTypeListSource','get');

    if~isempty(cachedDataSource)
        if any(strcmp(methods(class(cachedDataSource)),'hasSLDDAPISupport'))
            useBusEditor=true;
            if any(strcmp(methods(class(cachedDataSource)),'useBusEditor'))
                useBusEditor=cachedDataSource.useBusEditor;
            end
            assert(~useBusEditor);
        else
            assert(isa(cachedDataSource,'Simulink.dd.Connection'),...
            'New value should be a Simulink.dd.Connection object.');
            assert(cachedDataSource.isOpen);
            editorbtn.MatlabArgs={'Create',name,Simulink.data.DataDictionary(cachedDataSource.filespec)};
        end
    else
        editorbtn.MatlabArgs={'Create',name};
    end

    editorbtn.RowSpan=[1,1];
    editorbtn.ColSpan=[1,1];
    editorbtn.Tag='Editorbtn';
    editorbtn.UserData=name;

    spacerPanel.Type='panel';

    groupEditorBtn.Type='panel';
    groupEditorBtn.Tag='editorBtnPnl_tag';
    groupEditorBtn.Items={editorbtn,spacerPanel};
    groupEditorBtn.LayoutGrid=[1,3];
    groupEditorBtn.ColStretch=[0,1,1];

    rowIdx=rowIdx+1;








    addElementBtn.Type='pushbutton';
    addElementBtn.UserData=[];
    addElementBtn.RowSpan=[rowIdx,rowIdx];
    addElementBtn.ColSpan=[1,1];
    addElementBtn.Tag='AddElementBtn';
    addElementBtn.ToolTip=DAStudio.message('Simulink:busEditor:AddBusElementTooltip');

    deleteElementBtn.Type='pushbutton';
    deleteElementBtn.UserData=[];
    deleteElementBtn.RowSpan=[rowIdx,rowIdx];
    deleteElementBtn.ColSpan=[2,2];
    deleteElementBtn.Tag='DeleteElementBtn';

    moveElementUpBtn.Type='pushbutton';
    if~isempty(cachedDataSource)
        moveElementUpBtn.UserData.DataSource=cachedDataSource;
    else
        moveElementUpBtn.UserData.DataSource=[];
    end



    moveElementUpBtn.UserData.busObjectAppliedState=h;


    if~isfield(moveElementUpBtn.UserData,'tempBusObject')
        moveElementUpBtn.UserData.tempBusObject=h;
    end
    moveElementUpBtn.RowSpan=[rowIdx,rowIdx];
    moveElementUpBtn.ColSpan=[3,3];
    moveElementUpBtn.Tag='MoveElementUpBtn';

    moveElementDownBtn.Type='pushbutton';
    moveElementDownBtn.RowSpan=[rowIdx,rowIdx];
    moveElementDownBtn.ColSpan=[4,4];
    moveElementDownBtn.Tag='MoveElementDownBtn';

    buttonMenuGrp.LayoutGrid=[1,5];
    buttonMenuGrp.Type='panel';
    buttonMenuGrp.RowSpan=[rowIdx,rowIdx];
    buttonMenuGrp.ColSpan=[1,5];
    buttonMenuGrp.ColStretch=[0,0,0,0,1];
    buttonMenuGrp.Tag='buttonMenuGroup_tag';






    rowIdx=rowIdx+1;

    tempBusObject=moveElementUpBtn.UserData.tempBusObject;


    numElems=numel(tempBusObject.Elements);
    busobjectSpreadsheet.Type='spreadsheet';
    busobjectSpreadsheet.RowSpan=[1,numElems];



    isConnType=isa(h,'Simulink.ConnectionBus');

    isNonInherited=false;
    if~isConnType
        if slfeature('BusElSampleTimeDep')==1
            sampleTimeVals=arrayfun(@(el)el.SampleTime(1),tempBusObject.Elements);
            if any(sampleTimeVals~=-1)
                isNonInherited=true;
            end
        end
    end

    if isConnType
        busobjectSpreadsheet.ColSpan=[1,3];
    else

        if isNonInherited
            busobjectSpreadsheet.ColSpan=[1,10];
        else
            busobjectSpreadsheet.ColSpan=[1,9];
        end
    end

    busobjectSpreadsheet.Source=BusObjectSpreadsheet(h,cachedDataSource,name,isSlidStructureType);

    busobjectSpreadsheet.Tag='BusObjectSpreadsheet';
    busobjectSpreadsheet.SelectionChangedCallback=@(tag,sels,dlg)onspreadsheetcallback(tag,sels,dlg);
    busobjectSpreadsheet.Size=[300,300];
    if~isConnType
        busobjectSpreadsheet.Columns={DAStudio.message('Simulink:busEditor:PropElementName'),...
        DAStudio.message('Simulink:busEditor:PropDataType'),...
        DAStudio.message('Simulink:busEditor:PropComplexity'),...
        DAStudio.message('Simulink:busEditor:PropDimensions'),...
        DAStudio.message('Simulink:busEditor:PropMin'),...
        DAStudio.message('Simulink:busEditor:PropMax'),...
        DAStudio.message('Simulink:busEditor:PropDimensionsMode'),...
        DAStudio.message('Simulink:busEditor:PropSampleTime'),...
        DAStudio.message('Simulink:busEditor:PropUnits'),...
        DAStudio.message('Simulink:busEditor:PropDescription')};

        busobjectSpreadsheet.ColHeader={DAStudio.message('Simulink:busEditor:PropElementName'),...
        DAStudio.message('Simulink:busEditor:PropDataType'),...
        DAStudio.message('Simulink:busEditor:PropComplexity'),...
        DAStudio.message('Simulink:busEditor:PropDimensions'),...
        DAStudio.message('Simulink:busEditor:PropMin'),...
        DAStudio.message('Simulink:busEditor:PropMax'),...
        DAStudio.message('Simulink:busEditor:PropDimensionsMode'),...
        DAStudio.message('Simulink:busEditor:PropSampleTime'),...
        DAStudio.message('Simulink:busEditor:PropUnits'),...
        DAStudio.message('Simulink:busEditor:PropDescription')};

        if(slfeature('BusElSampleTimeDep')==1)&&(~isNonInherited)
            busobjectSpreadsheet.Columns(contains(busobjectSpreadsheet.Columns,DAStudio.message('Simulink:busEditor:PropSampleTime')))=[];

            busobjectSpreadsheet.ColHeader(contains(busobjectSpreadsheet.ColHeader,DAStudio.message('Simulink:busEditor:PropSampleTime')))=[];
        end
    else
        busobjectSpreadsheet.Columns={DAStudio.message('Simulink:busEditor:PropElementName'),...
        DAStudio.message('Simulink:busEditor:PropType'),...
        DAStudio.message('Simulink:busEditor:PropDescription')};

        busobjectSpreadsheet.ColHeader={DAStudio.message('Simulink:busEditor:PropElementName'),...
        DAStudio.message('Simulink:busEditor:PropType'),...
        DAStudio.message('Simulink:busEditor:PropDescription')};
    end

    busobjectSpreadsheet.Config=jsonencode(struct('enablesort',false,...
    'enablegrouping',false));
    busobjectSpreadsheet.LoadingCompleteCallback=@(tag,dlg)BusObjectSpreadsheetCBHandler.onLoadingCompleteCB(tag,dlg);
    busobjectSpreadsheet.Visible=true;

    addElementBtn.MatlabMethod='busddg_cb';
    addElementBtn.MaximumSize=[50,100];
    if isConnType
        addElementBtn.MatlabArgs={'addElement','%dialog','','Connection'};
        addElementBtn.FilePath=slprivate('getResourceFilePath','addinsert_connectionbuselement.png');
    else
        addElementBtn.MatlabArgs={'addElement','%dialog'};
        addElementBtn.FilePath=slprivate('getResourceFilePath','addinsert_buselement.png');
    end

    deleteElementBtn.MatlabMethod='busddg_cb';
    deleteElementBtn.MatlabArgs={'deleteElement','%dialog'};
    deleteElementBtn.FilePath=slprivate('getResourceFilePath','delete.png');
    deleteElementBtn.MaximumSize=[50,100];
    if isempty(tempBusObject.Elements)
        deleteElementBtn.Enabled=false;
        deleteElementBtn.ToolTip=DAStudio.message('Simulink:busEditor:DeleteBusElementDisabledTooltip');
    else
        deleteElementBtn.Enabled=true;
        deleteElementBtn.ToolTip=DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip');
    end

    moveElementUpBtn.MatlabMethod='busddg_cb';
    moveElementUpBtn.MatlabArgs={'moveElementUp','%dialog'};
    moveElementUpBtn.FilePath=slprivate('getResourceFilePath','up.png');
    moveElementUpBtn.MaximumSize=[50,100];
    moveElementUpBtn.Enabled=false;
    moveElementUpBtn.ToolTip=DAStudio.message('Simulink:busEditor:MoveBusElementUpDisabledNoElementSelections');

    moveElementDownBtn.MatlabMethod='busddg_cb';
    moveElementDownBtn.MatlabArgs={'moveElementDown','%dialog'};
    moveElementDownBtn.FilePath=slprivate('getResourceFilePath','down.png');
    moveElementDownBtn.MaximumSize=[50,100];
    moveElementDownBtn.Enabled=false;
    moveElementDownBtn.ToolTip=DAStudio.message('Simulink:busEditor:MoveBusElementDownDisabledNoElementSelections');



    spacer.Type='panel';
    buttonMenuGrp.Items={addElementBtn,deleteElementBtn,moveElementUpBtn,moveElementDownBtn,spacer};

    physmodHyperlink.Name=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLink');
    physmodHyperlink.Type='hyperlink';
    physmodHyperlink.Tag='physmodHyperlink';
    physmodHyperlink.MatlabMethod='helpview';
    physmodHyperlink.MatlabArgs={'simscape','DomainLineStyles'};
    physmodHyperlink.RowSpan=[rowIdx,rowIdx];
    physmodHyperlink.ColSpan=[1,4];
    physmodHyperlink.Enabled=true;
    physmodHyperlink.ToolTip=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLinkTooltip');
    physmodHyperlink.Alignment=1;

    if isConnType
        elementsgrp.Name=DAStudio.message('Simulink:dialog:ConnectionElementsgrpName');
    else
        elementsgrp.Name=DAStudio.message('Simulink:dialog:BusElementsgrpName');
    end
    elementsgrp.RowSpan=[rowIdx,rowIdx];
    elementsgrp.ColSpan=[1,3];
    elementsgrp.Type='group';
    elementsgrp.Flat=1;
    if isConnType
        elementsgrp.Items={busobjectSpreadsheet,physmodHyperlink};
    else
        elementsgrp.Items={busobjectSpreadsheet};
    end
    elementsgrp.Tag='BusElementsGrp';





    grpNumItems=0;
    if~isConnType
        grpCodeGen.Items={};





        grpNumItems=grpNumItems+1;
        dataScope.Name=DAStudio.message('Simulink:dialog:BusDataScopeLblName');
        dataScope.RowSpan=[1,1];
        dataScope.ColSpan=[1,3];
        dataScope.Type='combobox';
        dataScope.Entries={DAStudio.message('Simulink:dialog:Auto_CB'),DAStudio.message('Simulink:dialog:Exported_CB'),DAStudio.message('Simulink:dialog:Imported_CB')};
        dataScope.Tag='dataScope_tag';
        dataScope.Value=tempBusObject.DataScope;
        dataScope.MatlabMethod='busddg_cb';
        dataScope.MatlabArgs={'editDataScope','%dialog','%value'};

        grpCodeGen.Items{grpNumItems}=dataScope;






        grpNumItems=grpNumItems+1;
        headerFile.Name=DAStudio.message('Simulink:dialog:BusHeaderFileLblName');
        headerFile.RowSpan=[2,2];
        headerFile.ColSpan=[1,3];
        headerFile.Type='edit';
        headerFile.Tag='headerFile_tag';
        headerFile.Value=tempBusObject.HeaderFile;
        headerFile.MatlabMethod='busddg_cb';
        headerFile.MatlabArgs={'editHeaderFile','%dialog','%value'};

        grpCodeGen.Items{grpNumItems}=headerFile;





        grpNumItems=grpNumItems+1;
        alignment.Name=DAStudio.message('Simulink:dialog:StructtypeAlignmentLblName');
        alignment.RowSpan=[3,3];
        alignment.ColSpan=[1,3];
        alignment.Type='edit';
        alignment.Tag='busAlignment_tag';
        alignment.Value=tempBusObject.Alignment;
        alignment.MatlabMethod='busddg_cb';
        alignment.MatlabArgs={'editAlignment','%dialog','%value'};

        grpCodeGen.Items{grpNumItems}=alignment;

        if sl('busUtils','NDIdxBusUI')




            grpNumItems=grpNumItems+1;
            preserveDims.Name=DAStudio.message('Simulink:dialog:StructtypePreserveDimsLblName');
            preserveDims.RowSpan=[4,4];
            preserveDims.ColSpan=[1,3];
            preserveDims.Type='checkbox';
            preserveDims.Tag='PreserveDims_tag';
            preserveDims.Value=tempBusObject.PreserveElementDimensions;
            preserveDims.MatlabMethod='busddg_cb';
            preserveDims.MatlabArgs={'setPreserveDims','%dialog','%value'};

            grpCodeGen.Items{grpNumItems}=preserveDims;
        end



        rowIdx=rowIdx+1;
        grpCodeGen.Items=align_names(grpCodeGen.Items);
        if sl('busUtils','NDIdxBusUI')
            grpCodeGen.LayoutGrid=[5,2];
            grpCodeGen.RowStretch=[0,0,0,0,1];
        else
            grpCodeGen.LayoutGrid=[4,2];
            grpCodeGen.RowStretch=[0,0,0,1];
        end
        grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        grpCodeGen.Type='group';
        grpCodeGen.RowSpan=[rowIdx,rowIdx];
        grpCodeGen.ColSpan=[1,3];
        grpCodeGen.ColStretch=[0,1];
        grpCodeGen.Tag='grpCodeGen_tag';
    end





    rowIdx=rowIdx+1;
    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,3];
    description.Tag='description_tag';
    description.Value=tempBusObject.Description;
    description.MatlabMethod='busddg_cb';
    description.MatlabArgs={'editDescription','%dialog','%value'};





    [grpUserData,tabUserData]=get_userdata_prop_grp(h);














    tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tabDesign.LayoutGrid=[rowIdx,3];
    tabDesign.RowStretch=[zeros(1,rowIdx-1),1];
    tabDesign.ColStretch=[0,1,0];
    tabDesign.Items={buttonMenuGrp,elementsgrp,...
    description};
    tabDesign.Tag='TabDesign';





    if~isConnType
        tabCodeGen=createCodeGenTab(grpCodeGen);
    end









    if~isConnType
        [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'Bus','TabTwo');
    else
        [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'ConnectionBus','TabTwo');
    end




    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.DialogTag='BusObjectDialog';

    tabWhole.Type='tab';
    tabWhole.Tag='TabWhole';
    if isConnType
        tabWhole.Tabs={tabDesign};
    else
        tabWhole.Tabs={tabDesign,tabCodeGen};
    end

    if(~isempty(grpAdditional.Items))
        tabWhole.Tabs{end+1}=tabAdditionalProp;
    end

    if(~isempty(grpUserData.Items))
        tabWhole.Tabs{end+1}=tabUserData;
    end
    dlgstruct.Items={groupEditorBtn,tabWhole};


    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);
    dlgstruct.PostApplyCallback='busddg_applyrevertcbs';
    dlgstruct.PostApplyArgs={h,'postApply','%dialog'};
    dlgstruct.PostApplyArgsDT={'handle','string','handle'};

    dlgstruct.PostRevertCallback='busddg_applyrevertcbs';
    dlgstruct.PostRevertArgs={h,'postRevert','%dialog'};
    dlgstruct.PostRevertArgsDT={'handle','string','handle'};

    dlgstruct.OpenCallback=@onDialogOpen;


    dlgstruct.HelpMethod='helpview';
    if isConnType
        helpKey='simulink_connection_bus';
    else
        helpKey='simulink_bus';
    end
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],helpKey};
end





function onDialogOpen(dlg)
    dlgSrc=dlg.getDialogSource();
    if any(strcmp(methods(class(dlgSrc)),'useBusEditor'))
        dlg.setEnabled('Editorbtn',dlgSrc.useBusEditor());
        if any(strcmp(methods(class(dlgSrc)),'getUserData'))&&any(strcmp(methods(class(dlgSrc)),'setUserData'))
            dlgData=dlgSrc.getUserData;
            dlgData.Enabled.Editorbtn=dlgSrc.useBusEditor();
            dlgSrc.setUserData(dlgData);
        end
    end

    if any(strcmp(methods(class(dlgSrc)),'useCodeGen'))
        dlg.setVisible('TabCodeGen',dlgSrc.useCodeGen());
    end
end


function r=onspreadsheetcallback(~,sels,dlg)

    selectedRowsMap=containers.Map('KeyType','char','ValueType','double');

    for i=1:numel(sels)
        rowNumber=sels{i}.m_rowNumber;
        rowString=num2str(rowNumber);
        selectedRowsMap(rowString)=rowNumber;
    end

    busObjdlg=dlg;


    busObjdlg.setUserData('DeleteElementBtn',selectedRowsMap);



    DialogState=busObjdlg.getUserData('MoveElementUpBtn');
    tempBusObject=DialogState.tempBusObject;
    numElems=numel(tempBusObject.Elements);


    if isempty(selectedRowsMap)
        busObjdlg.setEnabled('AddElementBtn',true);
        busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementTooltip'));

        busObjdlg.setEnabled('MoveElementUpBtn',false);
        busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveBusElementUpDisabledNoElementSelections'));

        busObjdlg.setEnabled('MoveElementDownBtn',false);
        busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveBusElementDownDisabledNoElementSelections'));


        if numElems==0
            busObjdlg.setEnabled('DeleteElementBtn',false);
            busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementDisabledTooltip'));
        else
            busObjdlg.setEnabled('DeleteElementBtn',true);
            busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));
        end
        return;
    end


    if(selectedRowsMap.isKey("1")&&areRowsConsecutive(selectedRowsMap))
        busObjdlg.setEnabled('MoveElementUpBtn',false);
        busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveBusElementUpDisabledTooltipTopmostSelections'));


        if selectedRowsMap.isKey(num2str(numElems))
            busObjdlg.setEnabled('MoveElementDownBtn',false);
            busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveBusElementDownDisabledTooltipBottommostSelections'));
        else
            busObjdlg.setEnabled('MoveElementDownBtn',true);
            busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveDownBusElementTooltip'));
        end

        if length(selectedRowsMap)>1
            busObjdlg.setEnabled('AddElementBtn',false);
            busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementDisabledTooltip'));
        else
            busObjdlg.setEnabled('AddElementBtn',true);
            busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementTooltip'));
        end
        busObjdlg.setEnabled('DeleteElementBtn',true);
        busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));
        return;
    end


    if(selectedRowsMap.isKey(num2str(numElems))&&areRowsConsecutive(selectedRowsMap))
        busObjdlg.setEnabled('MoveElementDownBtn',false);
        busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveBusElementDownDisabledTooltipBottommostSelections'));


        if selectedRowsMap.isKey('1')
            busObjdlg.setEnabled('MoveElementUpBtn',false);
            busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveBusElementUpDisabledTooltipTopmostSelections'));
        else
            busObjdlg.setEnabled('MoveElementUpBtn',true);
            busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveUpBusElementTooltip'));
        end

        if length(selectedRowsMap)>1
            busObjdlg.setEnabled('AddElementBtn',false);
            busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementDisabledTooltip'));
        else
            busObjdlg.setEnabled('AddElementBtn',true);
            busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementTooltip'));
        end
        busObjdlg.setEnabled('DeleteElementBtn',true);
        busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));
        return;
    end


    if numel(selectedRowsMap.keys)==1
        busObjdlg.setEnabled('AddElementBtn',true);
        busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementTooltip'));

        busObjdlg.setEnabled('DeleteElementBtn',true);
        busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));

        busObjdlg.setEnabled('MoveElementUpBtn',true);
        busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveUpBusElementTooltip'));

        busObjdlg.setEnabled('MoveElementDownBtn',true);
        busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveDownBusElementTooltip'));
        return;
    end


    if areRowsConsecutive(selectedRowsMap)
        busObjdlg.setEnabled('AddElementBtn',false);
        busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementDisabledTooltip'));

        busObjdlg.setEnabled('DeleteElementBtn',true);
        busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));

        busObjdlg.setEnabled('MoveElementUpBtn',true);
        busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveUpBusElementTooltip'));

        busObjdlg.setEnabled('MoveElementDownBtn',true);
        busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveDownBusElementTooltip'));
        return;
    end


    busObjdlg.setEnabled('AddElementBtn',false);
    busObjdlg.updateToolTip('AddElementBtn',DAStudio.message('Simulink:busEditor:AddBusElementDisabledTooltip'));

    busObjdlg.setEnabled('DeleteElementBtn',true);
    busObjdlg.updateToolTip('DeleteElementBtn',DAStudio.message('Simulink:busEditor:DeleteBusElementTooltip'));

    busObjdlg.setEnabled('MoveElementUpBtn',false);
    busObjdlg.updateToolTip('MoveElementUpBtn',DAStudio.message('Simulink:busEditor:MoveBusElementUpDisabledTooltipDueToNonConsecutiveSelections'));

    busObjdlg.setEnabled('MoveElementDownBtn',false);
    busObjdlg.updateToolTip('MoveElementDownBtn',DAStudio.message('Simulink:busEditor:MoveBusElementDownDisabledTooltipDueToNonConsecutiveSelections'));
end

function busStruct=getBusStructForSlidStructureType(slidStructureType)
    obj=slidStructureType.getObject;
    elems=obj.Element;

    busStruct=Simulink.Bus;
    numElems=elems.Size;

    for i=1:numElems
        elem=elems.at(i);
        busElement=Simulink.BusElement;
        busElement.Name=elem.Name;
        busElement.Description=elem.Description;
        busElement.Dimensions=elem.Dimensions;
        busElement.SampleTime=-1;
        busElement.DimensionsMode='Fixed';
        busElement.DataType=elem.Type.TypeIdentifier;
        busElement.Min=elem.Type.Minimum;
        busElement.Max=elem.Type.Maximum;
        busElement.Unit=elem.Type.UnitExpression;

        if isequal(elem.Type.Complexity,1)
            busElement.Complexity='real';
        else
            busElement.Complexity='complex';
        end

        busStruct.Elements(i)=busElement;
    end
end

function isConsecutive=areRowsConsecutive(selectedRowsMap)

    isConsecutive=false;

    if length(selectedRowsMap)==1
        isConsecutive=true;
        return;
    end

    sortedRows=sort(str2double(selectedRowsMap.keys));
    if diff(sortedRows)==1
        isConsecutive=true;
    end
end

