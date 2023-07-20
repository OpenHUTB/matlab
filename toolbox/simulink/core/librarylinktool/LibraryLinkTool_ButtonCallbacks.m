function[status,message]=LibraryLinkTool_ButtonCallbacks(dialogH,action,varargin)

    try
        status=true;
        message='';

        switch action
        case{'doRestore','doPush'}

            spreadsheetTag=varargin{1};
            spreadsheetObj=dialogH.getUserData(spreadsheetTag);
            TopmostBlocks=findTopmostSelectedChildren(spreadsheetObj);

            if strcmp(action,'doPush')==1
                cmd='propagateHierarchy';
                actionOnPush=HandleConflictInPushOperation(dialogH,TopmostBlocks,true);
                if~actionOnPush
                    return;
                end
                pushBlocks=populateBlockNames(TopmostBlocks);
                blocksToProcess=pushBlocks;
                restoreBlocks={};
            else
                cmd='restoreHierarchy';
                restoreBlocks=populateBlockNames(TopmostBlocks);
                blocksToProcess=restoreBlocks;
                pushBlocks={};
            end

            actionStatus=examineLinks(restoreBlocks,pushBlocks);
            if~actionStatus
                return;
            end

            for i=1:length(blocksToProcess)
                block=blocksToProcess{i};
                handleStateTransitionTable(block);
                set_param(block,'LinkStatus',cmd);
            end


            updateToolAfterAction(dialogH,spreadsheetTag,spreadsheetObj);

        case{'doParameterizedRestore','doParameterizedPush'}
            spreadsheetTag=varargin{1};
            spreadsheetObj=dialogH.getUserData(spreadsheetTag);
            selectedBlocks=getSelectedBlocks(dialogH,spreadsheetTag);

            if strcmp(action,'doParameterizedPush')
                actionOnPush=HandleConflictInPushOperation(dialogH,selectedBlocks,false);
                if~actionOnPush
                    return;
                end

                cmd='propagateHierarchy';
            else
                cmd='restoreHierarchy';
            end

            selectedBlocksNames=populateBlockHandlesParameterized(selectedBlocks);

            for i=1:length(selectedBlocksNames)
                block=selectedBlocksNames{i};
                set_param(block,'LinkStatus',cmd);
            end

            updateToolAfterAction(dialogH,spreadsheetTag,spreadsheetObj);

        case 'doLibraryLinkHelp'
            activeTab=dialogH.getActiveTab('LibraryLinkToolTabContainer');
            if activeTab==0
                slprophelp('restore-disabled-links-id');
            else
                slprophelp('restore-parameterized-links-id');
            end

        end

    catch E
        throwAsCaller(E);
    end

end

function updateToolAfterAction(dialogH,spreadsheetTag,spreadsheetObj)

    updatedSpreadsheetObj=spreadsheetObj.updateSpreadsheetChildren();
    updatedSpreadsheetObj.m_SelectionCount=0;
    dialogH.setUserData(spreadsheetTag,updatedSpreadsheetObj);
    spreadsheetObj.updateUI(dialogH,spreadsheetTag);

    if strcmp(spreadsheetTag,'ParameterizedLinksSpreadsheet')==1
        dialogH.setEnabled('ParameterizedRestoreButton',false);
        dialogH.setEnabled('ParameterizedPushButton',false);
    else
        dialogH.setEnabled('PushButton',false);
        dialogH.setEnabled('RestoreButton',false);
    end

end


function action=HandleConflictInPushOperation(dialogH,blocks,isDisabled)
    M=containers.Map('KeyType','char','ValueType','any');
    isConflict=0;
    if isDisabled
        blocks=populateChildrenofCheckedDisableBlocks(blocks);
    end
    for i=1:length(blocks)
        if isDisabled
            blockName=blocks{i}.m_BlockName;
            blockHandle=get_param(blockName,'Handle');
            library=get_param(blockHandle,'AncestorBlock');
        else
            blockHandle=blocks{i}.m_ParameterizedBlockHandle;
            blockName=blocks{i}.m_ModifiedBlock;
            library=get_param(blockHandle,'ReferenceBlock');
        end
        if isKey(M,library)
            blocksInMap=M(library);
            blocksInMap{end+1}=blockName;
            M(library)=blocksInMap;
            isConflict=1;
        else
            blockInCellFormat{1}=blockName;
            M(library)=blockInCellFormat;
        end
    end
    action=true;
    if isConflict
        action=showPushConflictWarning(dialogH,M);
    end
end

function newBlocksList=populateChildrenofCheckedDisableBlocks(blocks)
    newBlocksList=blocks;
    for i=1:length(blocks)
        blockObj=blocks{i};
        children=populateChildren(blockObj.m_Children,{});
        for j=1:length(children)
            newBlocksList{end+1}=children{j};
        end
    end
end

function childrenList=populateChildren(children,childrenList)
    if isempty(children)
        return;
    end
    for i=1:length(children)
        childrenList{end+1}=children(i);
        child=children(i).m_Children;
        childrenList=populateChildren(child,childrenList);
    end
end

function action=showPushConflictWarning(dialogH,M)
    dialogH.setEnabled('ParameterizedRestoreButton',false);
    dialogH.setEnabled('ParameterizedPushButton',false);
    dialogH.setEnabled('RestoreButton',false);
    dialogH.setEnabled('PushButton',false);

    text='';
    key=keys(M);
    val=values(M);
    for i=1:length(M)
        value=val{i};
        if length(value)>1
            libraryLine=[DAStudio.message('Simulink:Libraries:LibraryLinkToolPushConflictLibBlock'),key{i}];
            text=[text,{''},libraryLine,DAStudio.message('Simulink:Libraries:LibraryLinkToolPushConflictConflictBlocks')];%#ok<AGROW>
            for j=1:length(value)
                blk=value{j};
                text=[text,blk];%#ok<AGROW>
            end
            text=[text,{''}];%#ok<AGROW>
        end
    end

    Msg1=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushConflictMsg1');
    Msg2=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushConflictMsg2');

    txt=[{Msg1},text,{Msg2}];
    title=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushConflictDialogTitle');
    choice=questdlg(txt,title');

    if strcmp(choice,'Yes')
        action=true;
    else
        action=false;
    end

    dialogH.setEnabled('ParameterizedRestoreButton',true);
    dialogH.setEnabled('ParameterizedPushButton',true);
    dialogH.setEnabled('RestoreButton',true);
    dialogH.setEnabled('PushButton',true);
end

function selectedBlocks=getSelectedBlocks(dialogH,spreadsheetTag)
    selectedBlocks={};
    spreadsheetObj=dialogH.getUserData(spreadsheetTag);
    children=spreadsheetObj.m_Children;
    for i=1:length(children)
        child=children(i);
        if child.m_Checkbox=='1'
            selectedBlocks{end+1}=child;
        end
    end
end

function BlocksHandles=populateBlockHandlesParameterized(BlockObjects)
    BlocksHandles={};
    for i=1:length(BlockObjects)
        BlocksHandles{end+1}=BlockObjects{i}.m_ParameterizedBlockHandle;
    end
end

function BlocksList=populateBlockNames(BlockObjects)
    BlocksList={};
    for i=1:length(BlockObjects)
        BlocksList{end+1}=BlockObjects{i}.m_BlockName;
    end
end

function actionStatus=examineLinks(restoreBlocks,pushBlocks)

    actionStatus=true;
    lostChanges=slInternal('examineLinks',restoreBlocks,pushBlocks);
    lostChangeBlocks=getfullname(lostChanges);
    if~iscell(lostChangeBlocks)
        lostChangeBlocks={lostChangeBlocks};
    end


    if~isempty(lostChangeBlocks)
        disc1=DAStudio.message('Simulink:dialog:LinkDiscard1');
        disc2=DAStudio.message('Simulink:dialog:LinkDiscard2');
        disc3=DAStudio.message('Simulink:dialog:LinkDiscard3');

        txt=[{disc1},{''},restoreBlocks,{''},{disc2},{''},lostChangeBlocks];

        Cancel=DAStudio.message('Simulink:editor:DialogCancel');
        OK=DAStudio.message('Simulink:editor:DialogOK');

        actionStatus=false;
        choice=questdlg(txt,disc3,OK,Cancel,Cancel);
        if strcmp(choice,OK)
            actionStatus=true;
        end
    end
end

function topmostBlocks=findTopmostSelectedChildren(row)
    children=row.m_Children;
    topmostBlocks={};
    if isempty(children)
        return;
    end
    for i=1:length(children)
        topChild={};
        child=children(i);
        if child.m_Selected=='1'
            topChild=child;
            topmostBlocks{end+1}=topChild;
        else
            topChildFromHierarchy=findTopmostSelectedChildren(child);
            if~isempty(topChildFromHierarchy)
                if iscell(topChildFromHierarchy)
                    for j=1:length(topChildFromHierarchy)
                        topmostBlocks(end+1)=topChildFromHierarchy(j);
                    end
                else
                    topmostBlocks{end+1}=topChildFromHierarchy;
                end
            end
        end
    end
end

function handleStateTransitionTable(block)

    if strcmp(get_param(block,'BlockType'),'SubSystem')&&...
        strcmp(get_param(block,'SFBlockType'),'State Transition Table')
        blkHandle=get_param(block,'Handle');
        chartId=sfprivate('block2chart',blkHandle);

        if chartId~=0








            editors=sfprivate('studio_redirect','find_all_editors_for_chart',...
            chartId,blkHandle);

            for editor=editors(:)'
                studio=editor.getStudio();
                if SLM3I.SLCommonDomain.isWebContentShowingForEditor(editor)&&...
                    ~(studio.getTabCount()==1)
                    tabId=studio.getTabByComponent(editor);
                    studio.destroyTab(tabId);
                end
            end
        end

    end
end



