function createFromSelectionCB(userdata,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    actionMsgId=userdata;
    SFStudio.Utils.sfMarqueeActionUtils.requireEditor(editor,actionMsgId);

    switch(actionMsgId)
    case 'Stateflow:studio:SFCreateState'
        loc_createState(editor,StateflowDI.StateType.NormalState,false);
    case 'Stateflow:studio:SFCreateSubchart'
        loc_createState(editor,StateflowDI.StateType.NormalState,true);
    case 'Stateflow:studio:SFCreateBox'
        loc_createState(editor,StateflowDI.StateType.Box,false);
    case 'Stateflow:studio:SFCreateSubchartedbox'
        loc_createState(editor,StateflowDI.StateType.Box,true);
    otherwise
        disp(['Invalid actionMsgId:',actionMsgId])
    end
end

function loc_createState(editor,typeToCreate,isSubcharted)
    marqueeBounds=[0,0,0,0];
    undoId=loc_getToolCreationMessageId(typeToCreate);
    editor.createMCommand(undoId,DAStudio.message(undoId),...
    @SFStudio.Utils.sfMarqueeActionUtils.createStateAndCacheId,{editor,typeToCreate,marqueeBounds,false});
    stateId=SFStudio.Utils.sfMarqueeActionUtils.createStateAndCacheId(editor,typeToCreate,marqueeBounds,true);

    if(isSubcharted)
        StateflowDI.Util.toggleIsSubchart(stateId);
    end

    SFStudio.Utils.sfMarqueeActionUtils.enterLabelEditMode(editor,stateId);
end

function toolCreationMsgId=loc_getToolCreationMessageId(typeToCreate)
    toolCreationMsgId=[];
    switch(typeToCreate)
    case StateflowDI.StateType.NormalState
        toolCreationMsgId='Stateflow:studio:SFStateCreationToolStateCreation';
    case StateflowDI.StateType.Box
        toolCreationMsgId='Stateflow:studio:SFCreateBox';
    otherwise
        disp('Invalid type to create in toolbox\stateflow\ui\studio\config\m\createFromSelectionCB.m')
    end
end
