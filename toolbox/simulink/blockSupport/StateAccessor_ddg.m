function dlgStruct=StateAccessor_ddg(source,h)



    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    if isempty(findprop(source,'UDTHighlighted'))
        addProp(source,'UDTHighlighted','mxArray');
        source.UDTHighlighted=[];
    end

    blockPathHandles=studioHighlight_cb('getBlockPathHandles',gcbp);




    isStateOwnerBlockEnabled=~source.isHierarchySimulating;
    if isStateOwnerBlockEnabled
        isStateOwnerBlockEnabled=~h.isReadonlyProperty('StateOwnerBlock');
    end


    paramGrp_1.Items={};
    rowVal=1;
    rowStretch=[];

    rowStretch(rowVal)=0;

    stateOwnerBlkLbl.Name=DAStudio.message('Simulink:dialog:StateOwnerBlock');
    stateOwnerBlkLbl.Type='text';
    stateOwnerBlkLbl.RowSpan=[rowVal,rowVal];
    stateOwnerBlkLbl.ColSpan=[1,1];
    stateOwnerBlkLbl.Enabled=isStateOwnerBlockEnabled;
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=stateOwnerBlkLbl;

    stateOwnerBlkLink.Name=get_param(h.Handle,'StateOwnerBlock');
    if(strcmp(stateOwnerBlkLink.Name,'')==0)
        stateOwnerBlkLink.Type='hyperlink';
        stateOwnerBlkLink.MatlabMethod='StateAccessor_ddg_cb';
        stateOwnerBlkLink.MatlabArgs={h.handle,'hilite',stateOwnerBlkLink.Name,blockPathHandles};
        stateOwnerBlkLink.Visible=true;
    else
        stateOwnerBlkLink.Name='';
        stateOwnerBlkLink.Type='hyperlink';
        stateOwnerBlkLink.Visible=false;
    end
    stateOwnerBlkLink.RowSpan=[rowVal,rowVal];
    stateOwnerBlkLink.ColSpan=[2,2];
    stateOwnerBlkLink.Enabled=isStateOwnerBlockEnabled;
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=stateOwnerBlkLink;



    paramGrp_1.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp_1.Type='group';
    paramGrp_1.LayoutGrid=[rowVal,2];
    paramGrp_1.ColStretch=[0,1];
    paramGrp_1.RowStretch=rowStretch;
    paramGrp_1.RowSpan=[2,2];
    paramGrp_1.ColSpan=[1,1];
    paramGrp_1.Source=h;









    paramGrp_Tree.Items={};
    rowVal=1;



    if isempty(findprop(source,'UDTSOSobj'))
        addSOSobjProp(source,'UDTSOSobj','mxArray');
        if isempty(findprop(source,'UDTerrSelectorTree'))
            addProp(source,'UDTerrSelectorTree','mxArray');
        end
        source.UDTerrSelectorTree=false;
    end




    rowVal=rowVal+1;
    rowStretch(rowVal)=0;

...
...
...
...
...
...
...

    hiliteButton.Enabled=false;
    block2hilite='';
    if~isempty(source.UDTSOSobj)
        block2hilite=source.UDTSOSobj.TreeSelectedItem;
        if~isempty(block2hilite)
            hiliteButton.Enabled=true;
        end
    end

    try
        block2hiliteH=get_param(block2hilite,'Handle');
    catch
        block2hiliteH=-1;
    end
    hiliteButton.ToolTip=DAStudio.message('Simulink:dialog:HighlightSelectedBlock');
    hiliteButton.Tag='HiliteButton';
    hiliteButton.Type='pushbutton';
    hiliteButton.Name=DAStudio.message('Simulink:dialog:Highlight');
    hiliteButton.RowSpan=[rowVal,rowVal];
    hiliteButton.ColSpan=[2,2];
    hiliteButton.MatlabMethod='StateAccessor_ddg_cb';
    hiliteButton.MatlabArgs={h.handle,'hilite',block2hiliteH,blockPathHandles};
    paramGrp_Tree.Items{length(paramGrp_Tree.Items)+1}=hiliteButton;



    refreshButton.Tag='RefreshButton';
    refreshButton.Type='pushbutton';
    refreshButton.Name=DAStudio.message('Simulink:dialog:CapitalRefresh');
    refreshButton.ToolTip=DAStudio.message('Simulink:dialog:RefreshTree');
    refreshButton.RowSpan=[rowVal,rowVal];
    refreshButton.ColSpan=[3,3];
    refreshButton.Enabled=isStateOwnerBlockEnabled;
    refreshButton.MatlabMethod='StateAccessor_ddg_cb';
    refreshButton.MatlabArgs={h.handle,'callRefreshButton','%dialog'};
    paramGrp_Tree.Items{length(paramGrp_Tree.Items)+1}=refreshButton;




    if~isempty(source.UDTSOSobj)
        SOSobj=source.UDTSOSobj;





        rowVal=rowVal+1;
        rowStretch(rowVal)=0;



        hierTree.Type='tree';
        hierTree.Name=DAStudio.message('Simulink:dialog:StateOwnerTree');
        hierTree.Tag='tree_SystemHierarchy';
        hierTree.RowSpan=[rowVal,rowVal];
        hierTree.ColSpan=[1,4];
        hierTree.ExpandTree=false;
        hierTree.TreeModel=SOSobj.TreeModel;
        hierTree.TreeExpandItems=SOSobj.TreeExpandItems;

        hierTree.DialogRefresh=false;
        hierTree.Visible=true;
        hierTree.Enabled=isStateOwnerBlockEnabled;
        hierTree.ObjectProperty='SelectedStateOwner';
        hierTree.MatlabMethod='StateAccessor_ddg_cb';
        hierTree.MatlabArgs={h.Handle,'selectionTree',SOSobj,'%value','%dialog'};




        if(source.UDTerrSelectorTree)
            hierTree.Visible=false;
            treeRefreshMsg.Type='textbrowser';
            ErrorBlockDiagramMsg1=DAStudio.message('Simulink:blocks:StateReadWriteBlockDiagramChanged1');
            ErrorBlockDialgramMsg2=DAStudio.message('Simulink:blocks:StateReadWriteBlockDiagramChanged2');
            bHdlStr=studioHighlight_cb('getStringForHandle',h.handle);
            msg1=[...
'<html><body padding="0" spacing="0">'...
            ,'<table width="100%" cellpadding="0" cellspacing="0">'...
            ,'<tr>'...
            ,'<td align="center"><b>',ErrorBlockDiagramMsg1,' '];
            RefreshLink=['<a href='...
            ,'"matlab:eval(''StateAccessor_ddg_cb(str2num(''''',bHdlStr,'''''),''''callRefreshButton, %dialog'''');'')">',rtwprivate('rtwhtmlescape',DAStudio.message('Simulink:dialog:DsmRwGuiRefresh')),'</a>'];
            msg2=[' ',ErrorBlockDialgramMsg2,'</b></td></tr>'...
            ,'</table></body></html>'];
            treeRefreshMsg.Text=[msg1,RefreshLink,msg2];
            treeRefreshMsg.RowSpan=[rowVal,rowVal];
            treeRefreshMsg.ColSpan=[1,4];
            paramGrp_Tree.Items{length(paramGrp_Tree.Items)+1}=treeRefreshMsg;
        else
            paramGrp_Tree.Items{length(paramGrp_Tree.Items)+1}=hierTree;
        end


    end




    paramGrp_Tree.Name='';
    paramGrp_Tree.Type='group';
    paramGrp_Tree.LayoutGrid=[rowVal,4];
    paramGrp_Tree.RowStretch=zeros(1,rowVal);
    paramGrp_Tree.ColStretch=[0,0,0,0];
    paramGrp_Tree.RowSpan=[3,3];
    paramGrp_Tree.ColSpan=[1,1];
    paramGrp_Tree.Source=h;



    paramGrp_Related.Items={};
    rowVal=1;


    nRead=length(h.ComputedStateAccessorInfo.relatedStateReadBlocks);

    stateReadBlks.Type='textbrowser';
    stateReadBlks.Text=StateAccessor_ddg_cb(h.Handle,'getStateReadBlksHTML');
    stateReadBlks.RowSpan=[rowVal,rowVal];
    stateReadBlks.ColSpan=[1,1];
    stateReadBlks.Tag='stateReadBlks';
    paramGrp_Related.Items{length(paramGrp_Related.Items)+1}=stateReadBlks;
    rowVal=rowVal+1;

    stateWriteBlks.Type='textbrowser';
    stateWriteBlks.Text=StateAccessor_ddg_cb(h.Handle,'getStateWriteBlksHTML');
    stateWriteBlks.RowSpan=[rowVal,rowVal];
    stateWriteBlks.ColSpan=[1,1];
    stateWriteBlks.Tag='stateWriteBlks';
    paramGrp_Related.Items{length(paramGrp_Related.Items)+1}=stateWriteBlks;


    paramGrp_Related.Name='';
    paramGrp_Related.Type='group';
    paramGrp_Related.LayoutGrid=[rowVal,1];
    paramGrp_Related.RowStretch=zeros(1,rowVal);
    paramGrp_Related.ColStretch=[0];
    paramGrp_Related.RowSpan=[4,4];
    paramGrp_Related.ColSpan=[1,1];
    paramGrp_Related.Source=h;





    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',...
    strrep(h.Name,sprintf('\n'),' '));
    if(strcmp(h.BlockType,'StateWriter'))
        dlgStruct.DialogTag=['StateWriter',num2str(h.handle)];
    else
        assert(strcmp(h.BlockType,'StateReader'))
        dlgStruct.DialogTag=['StateReader',num2str(h.handle)];
    end

    dlgStruct.Items={descGrp,paramGrp_1,paramGrp_Tree,paramGrp_Related};
    dlgStruct.LayoutGrid=[4,1];
    dlgStruct.RowStretch=[0,0,0,0];
    dlgStruct.CloseCallback='StateAccessor_ddg_cb';
    dlgStruct.CloseArgs={h.Handle,'doClose','%dialog'};
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyCallback='StateAccessor_ddg_cb';
    dlgStruct.PreApplyArgs={h.Handle,'doPreApply','%dialog'};

    dlgStruct.PostApplyCallback='StateAccessor_ddg_cb';
    dlgStruct.PostApplyArgs={h.Handle,'doPostApply','%dialog'};
    dlgStruct.PostApplyArgsDT={'handle','string','handle'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    dlgStruct.OpenCallback=@createTree;
    function createTree(dlg)
        StateAccessor_ddg_cb(h.handle,'callRefreshButton',dlg);
        if slfeature('ParameterWriteToGeneralBlocks')>=2&&...
            checkOwnerNoSelectState(dlg)
            dlg.enableApplyButton(true);
        else
            dlg.enableApplyButton(false);
        end
    end
    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end

function[dtaOn]=setupMoreLessButton(hDlgSource,dtTag,dtaOn)

    dtipOpen=false;
    try




        if isempty(findprop(hDlgSource,'UDTAssistOpen'))
            addInstanceProp(hDlgSource,'UDTAssistOpen','mxArray');
        end




        if isempty(findprop(hDlgSource,'UDTIPOpen'))
            addInstanceProp(hDlgSource,'UDTIPOpen','mxArray');
        end

        if isempty(hDlgSource.UDTAssistOpen)





            hDlgSource.UDTAssistOpen.tags={dtTag};
            hDlgSource.UDTAssistOpen.status={dtaOn};

        else


            whichTag=find(strcmp(dtTag,hDlgSource.UDTAssistOpen.tags),1);
            if isempty(whichTag)
                hDlgSource.UDTAssistOpen.tags=[hDlgSource.UDTAssistOpen.tags{:},{dtTag}];
                hDlgSource.UDTAssistOpen.status=[hDlgSource.UDTAssistOpen.status{:},{dtaOn}];
            else
                dtaOn=hDlgSource.UDTAssistOpen.status{whichTag};
            end
        end




        if isempty(findprop(hDlgSource,'UDTIPOpen'))
            addInstanceProp(hDlgSource,'UDTIPOpen','mxArray');
        end

        if isempty(hDlgSource.UDTIPOpen)



            hDlgSource.UDTIPOpen.tags={dtTag};
            hDlgSource.UDTIPOpen.status={dtipOpen};
        else


            whichTag=find(strcmp(dtTag,hDlgSource.UDTIPOpen.tags),1);
            if isempty(whichTag)
                hDlgSource.UDTIPOpen.tags=[hDlgSource.UDTIPOpen.tags{:},{dtTag}];
                hDlgSource.UDTIPOpen.status=[hDlgSource.UDTIPOpen.status{:},{dtipOpen}];
            else
                dtipOpen=hDlgSource.UDTIPOpen.status{whichTag};
            end

        end
    catch ME
        if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')...
            ||strcmp(ME.identifier,'MATLAB:UndefinedFunction')


        else
            rethrow(ME);
        end
    end
end

function addInstanceProp(hDlgSource,propName,propType)

    switch Simulink.data.getScalarObjectLevel(hDlgSource)
    case 1
        hProp=schema.prop(hDlgSource,propName,propType);
        hProp.AccessFlags.Serialize='off';
        hProp.Visible='off';
    case 2
        hProp=addprop(hDlgSource,propName);
        hProp.Transient=true;
        hProp.Hidden=true;
    otherwise
        assert(false);
    end
end

function stateNotSet=checkOwnerNoSelectState(dlg)

    source=dlg.getDialogSource;
    selStateOwner=source.UDTSOSobj.SelectedStateOwner;
    selStateName=source.UDTSOSobj.SelectedOwnerState;
    if~isempty(selStateOwner)
        stateNames=get_param(selStateOwner,'StateNameList');
    end
    stateNotSet=~isempty(selStateOwner)&&...
    (isempty(selStateName)||...
    (length(stateNames)>1&&strcmp(selStateName,'<default>')));
end

function addStateOwnerLinkProp(source,propName,propType)
    hProp=schema.prop(source,propName,propType);
end

function addSOSobjProp(source,propName,propType)
    hProp=schema.prop(source,propName,propType);
end

function addProp(source,propName,propType)
    hProp=schema.prop(source,propName,propType);
end

function moreButton=getPushButtonWidget_More(dtTag,h)

    moreButton.Tag=[dtTag,'|','UDTShowDataTypeAssistBtn'];
    moreButton.Type='pushbutton';
    moreButton.Name='>>';



    moreButton.MatlabMethod='StateAccessor_ddg_cb';
    moreButton.MatlabArgs={h.handle,'callMoreButton','buttonPushEvent','%dialog','%tag'};




end

function lessButton=getPushButtonWidget_Less(dtTag)

    lessButton.Tag=[dtTag,'|','UDTHideDataTypeAssistBtn'];
    lessButton.Type='pushbutton';
    lessButton.Name='<<';

    lessButton.MatlabMethod='Simulink.DataTypePrmWidget.callbackDataTypeWidget';
    lessButton.MatlabArgs={'buttonPushEvent','%dialog','%tag'};

end


