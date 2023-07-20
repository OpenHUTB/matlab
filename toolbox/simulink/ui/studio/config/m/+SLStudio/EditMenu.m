function schema=EditMenu(fncname,cbinfo)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end



















function schema=CopyToClipboardMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:CopyViewToClipboardMenu';
    schema.label=DAStudio.message('Simulink:studio:CopyViewToClipboardMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:CopyMetaViewToClipboard'),...
    im.getAction('Simulink:CopyBitmapViewToClipboard')
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end



function schema=CopyViewToClipboard(~)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardToolTip');
    schema.tag='Simulink:CopyViewToClipboard';
    schema.label=DAStudio.message('Simulink:studio:CopyViewToClipboard');
    schema.callback=@CopyBitmapViewToClipboardCB;

    schema.autoDisableWhen='Never';
end





function schema=CopyBitmapViewToClipboard(cbinfo)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardToolTip');
    schema.tag='Simulink:CopyBitmapViewToClipboard';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:CopyBitmapViewToClipboard');
    end
    schema.callback=@CopyBitmapViewToClipboardCB;

    schema.autoDisableWhen='Never';
end



function CopyBitmapViewToClipboardCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    slActiveEditor=slStudioApp.getActiveEditor;
    canvas=slActiveEditor.getCanvas;
    p=GLUE2.Portal;
    p.pathXStyle=get_param(0,'EditorPathXStyle');
    p.clipboardOptions.format='BITMAP';
    p.clipboardOptions.backgroundColorMode=get_param(0,'ClipboardBackgroundColorMode');
    p.toClipboard(canvas);

    SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardEphemeralTitle'),DAStudio.message('Simulink:studio:CopyBitmapViewToClipboardEphemeralText'));
end




function schema=CopyMetaViewToClipboard(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:CopyMetaViewToClipboardStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:CopyMetaViewToClipboardToolTip');
    schema.tag='Simulink:CopyMetaViewToClipboard';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:CopyMetaViewToClipboard');
    end
    schema.userdata=schema.tag;
    schema.callback=@CopyMetaViewToClipboardCB;

    schema.autoDisableWhen='Never';
end



function schema=CopyMetaViewToClipboardSF(cbinfo)%#ok<DEFNU>
    schema=CopyMetaViewToClipboard(cbinfo);
    schema.callback=@CopyMetaViewToClipboardSFCB;
end



function CopyMetaViewToClipboardCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    slActiveEditor=slStudioApp.getActiveEditor;
    canvas=slActiveEditor.getCanvas;
    p=GLUE2.Portal;
    p.pathXStyle=get_param(0,'EditorPathXStyle');
    slObj=get_param(gcs,'Object');
    p.setTarget('Simulink',slObj);
    p.targetScene.Background.Color=SLPrint.Utils.GetBGColor(slObj);
    p.clipboardOptions.format='META';
    p.clipboardOptions.EMFGenType=4;
    p.clipboardOptions.backgroundColorMode=get_param(0,'ClipboardBackgroundColorMode');
    p.toClipboard(canvas);
end



function CopyMetaViewToClipboardSFCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    sfEditor=slStudioApp.getActiveEditor;
    canvas=sfEditor.getCanvas;
    chartId=double(sfEditor.getDiagram().backendId);
    p=GLUE2.Portal;
    p.pathXStyle=get_param(0,'EditorPathXStyle');
    p.setTarget('Stateflow',chartId);
    sfObj=idToHandle(sfroot,chartId);
    p.targetScene.Background.Color=SLPrint.Utils.GetBGColor(sfObj);
    p.clipboardOptions.format='META';
    p.clipboardOptions.EMFGenType=4;
    p.clipboardOptions.backgroundColorMode=get_param(0,'ClipboardBackgroundColorMode');
    p.toClipboard(canvas);
end

function schema=PasteDuplicateInportDisabled(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:PasteDuplicate';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:PasteDuplicate');
    schema.icon=schema.tag;
    if SLStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='Hidden';
    else
        schema.state='Disabled';
    end
end

function schema=PasteDuplicateInport(cbinfo)%#ok<DEFNU>
    schema=PasteDuplicateInportDisabled(cbinfo);
    schema.userdata=schema.tag;
    pasteDuplicateEnabled=false;
    if(ismethod(cbinfo.domain,('canPasteDuplicate')))
        pasteDuplicateEnabled=cbinfo.domain.canPasteDuplicate(cbinfo.uiObject.handle);
    end
    if~pasteDuplicateEnabled||SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.callback=@PasteDuplicateInportCB;
end

function PasteDuplicateInportCB(cbinfo)
    cbinfo.domain.doPasteDuplicateInport(cbinfo.isContextMenu);
end

function schema=SelectAll(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SelectAll';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='selectAll';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SelectAll');
    end
    schema.accelerator='Ctrl+A';
    if SLStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='Hidden';
    elseif isvalid(cbinfo.studio.App.getActiveEditor)&&...
        ~SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.callback=@SelectAllCB;

    schema.autoDisableWhen='Never';
end

function schema=SelectAllSF(cbinfo)%#ok<DEFNU>
    schema=SelectAll(cbinfo);
    schema.obsoleteTags={'Stateflow:SelectAllMenuItem'};
    schema.state=SFStudio.Utils.getStateForAuthoredCharts(cbinfo,schema.state);
end

function SelectAllCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    editor.selectAll;
end

function schema=Delete(cbinfo)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:Delete';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Delete');
    schema.accelerator='delete';

    if~SLStudio.Utils.isInterfaceViewActive(cbinfo)&&SLStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='Hidden';

    elseif SFStudio.Utils.isTruthTable(cbinfo)
        schema.state='Enabled';

    elseif~cbinfo.domain.canDelete(cbinfo.isContextMenu)||SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    schema.callback=@DeleteCB;
end

function DeleteCB(cbinfo)
    if SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.deleteSelection(subviewerId);
    else
        cbinfo.domain.delete(cbinfo.isContextMenu);
    end
end





function[uncomm,commOut,commThru]=loc_getCommentedStateOfBlocks(cbinfo)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    uncomm=0;commOut=0;commThru=0;

    for i=1:length(blockHandles)
        switch get_param(blockHandles(i),'Commented')
        case 'off'
            uncomm=uncomm+1;
        case 'on'
            commOut=commOut+1;
        case 'through'
            commThru=commThru+1;
        end
    end
end

function schema=CommentThruBlocks(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:CommentThru';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:CommentThru');
    end

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    else
        [uncomm,commOut,~]=loc_getCommentedStateOfBlocks(cbinfo);
        if(uncomm==0&&commOut==0)

            schema.userdata='off';
            schema.state='Disabled';

            if~SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label=DAStudio.message('Simulink:studio:CommentThru');
            end
        else
            schema.userdata='through';
            schema.state='Enabled';
            if~SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label=DAStudio.message('Simulink:studio:CommentThru');
            end
        end
    end

    schema.callback=@CommentThruBlocksCB;
end

function CommentThruBlocksCB(cbinfo,~)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    numBlocks=length(blockHandles);
    editor=[];
    editorDomain=[];
    if slfeature('SelectiveParamUndoRedo')>0
        if(numBlocks>0)
            editor=cbinfo.studio.App.getActiveEditor;
            if(~isempty(editor))
                editorDomain=editor.getStudio.getActiveDomain();
            end
        end
    end

    if~isempty(editorDomain)

        editorDomain.createParamChangesCommand(...
        editor,...
        'Simulink:studio:BlockCommenting',...
        DAStudio.message('Simulink:studio:BlockCommenting'),...
        @CommentThruBlocksCB_Impl,...
        {cbinfo,editorDomain},...
        false,...
        false,...
        false,...
        true,...
        true);
    else
        CommentThruBlocksCB_Impl(cbinfo,[]);
    end
end

function[success,noop]=CommentThruBlocksCB_Impl(cbinfo,editorDomain)
    success=true;
    noop=false;%#ok
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    errBlkH=[];
    numBlocks=length(blockHandles);

    msg=[];
    for index=1:numBlocks
        blockH=blockHandles(index);
        try
            if(~isempty(editorDomain))
                editorDomain.paramChangesCommandAddObject(blockH);
            end

            set_param(blockH,'Commented',cbinfo.userdata);
        catch e
            errBlkH(end+1)=blockH;%#ok
            msg=e.message;
        end
    end




    if length(errBlkH)>1
        msg=[DAStudio.message('Simulink:studio:CommentThruNotSupported'),newline,newline];
        for index=1:length(errBlkH)
            msg=[msg,strrep(getfullname(errBlkH(index)),newline,' '),newline];%#ok
        end
    end
    if~isempty(errBlkH)
        dp=DAStudio.DialogProvider;
        dp.warndlg(msg,'',true);
    end

    noop=length(errBlkH)==numBlocks;
end




function schema=CommentBlocks(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:Comment';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:Comment');
    end

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    else
        [uncomm,~,commThru]=loc_getCommentedStateOfBlocks(cbinfo);
        if(uncomm==0&&commThru==0)

            schema.state='Disabled';
        else

            schema.userdata='on';
            schema.state='Enabled';
        end
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='commentOut';
    end

    schema.callback=@CommentBlocksCB;
end


function schema=unCommentBlocks(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:Uncomment';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:Uncomment');
    end

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    else
        [~,commOut,commThru]=loc_getCommentedStateOfBlocks(cbinfo);
        if(commOut==0&&commThru==0)

            schema.state='Disabled';
        else

            schema.userdata='off';
            schema.state='Enabled';
        end
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='commentOutRemove';
    end

    schema.callback=@CommentBlocksCB;
end

function CommentBlocksCB(cbinfo,~)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    numBlocks=length(blockHandles);
    editor=[];
    editorDomain=[];
    if slfeature('SelectiveParamUndoRedo')>0
        if(numBlocks>0)
            editor=cbinfo.studio.App.getActiveEditor;
            if(~isempty(editor))
                editorDomain=editor.getStudio.getActiveDomain();
            end
        end
    end

    if~isempty(editorDomain)

        editorDomain.createParamChangesCommand(...
        editor,...
        'Simulink:studio:BlockCommenting',...
        DAStudio.message('Simulink:studio:BlockCommenting'),...
        @CommentBlocksCB_Impl,...
        {cbinfo,editorDomain},...
        false,...
        false,...
        false,...
        true,...
        true);
    else
        CommentBlocksCB_Impl(cbinfo,[]);
    end
end

function[success,noop]=CommentBlocksCB_Impl(cbinfo,editorDomain)
    success=true;
    noop=false;%#ok
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    errBlkH=[];
    numBlocks=length(blockHandles);

    for index=1:numBlocks
        blockH=blockHandles(index);
        try
            if(~isempty(editorDomain))
                editorDomain.paramChangesCommandAddObject(blockH);
            end

            set_param(blockH,'Commented',cbinfo.userdata);
        catch
            errBlkH(end+1)=blockH;%#ok
        end
    end


    if~isempty(errBlkH)
        message=[DAStudio.message('Simulink:studio:CommentNotSupported'),sprintf('\n'),sprintf('\n')];
        for index=1:length(errBlkH)
            message=[message,strrep(getfullname(errBlkH(index)),sprintf('\n'),' '),sprintf('\n')];%#ok
        end
        dp=DAStudio.DialogProvider;
        dp.warndlg(message,'',true);
    end

    noop=length(errBlkH)==numBlocks;
end

function schema=FindReferencedVariables(cbinfo)%#ok<DEFNU>
    schema=FindReferencedVariablesSF(cbinfo);

    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)
        if SLStudio.Utils.objectIsValidBlock(obj)
            if~SLStudio.Utils.objectIsValidScopeBlock(obj)
                schema.state='Enabled';
            elseif cbinfo.isContextMenu
                schema.state='Hidden';
            end
        elseif isa(obj,'SLM3I.Diagram')
            schema.state='Enabled';
        elseif(SLStudio.Utils.isInterfaceViewActive(cbinfo)&&...
            isa(obj,'InterfaceEditor.InterfaceBlock'))
            schema.state='Enabled';
        end
    elseif cbinfo.selection.size==0

        schema.state='Enabled';
    end

    schema.callback=@FindReferencedVariablesCB;

    schema.autoDisableWhen='Never';
end

function schema=FindReferencedVariablesSF(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:FindReferencedVariables');
    schema.tag='Simulink:VariablesUsed';
    schema.state='Disabled';
end

function FindReferencedVariablesCB(cbinfo)


    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)&&SLStudio.Utils.objectIsValidBlock(obj)
        context=obj.getFullPathName;
    else
        context=SLStudio.Utils.getDiagramFullName(cbinfo);
    end

    slprivate('findVarsDoMESearch',context);
end

function schema=FindReferencedVariablesInRefMdl(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:FindReferencedVariablesInRefMdl');
    schema.tag='Simulink:VariablesUsedInRefMdl';
    schema.state='Disabled';

    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)&&slfeature('FindVarsFromWithinSubModel')>0
        if SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(obj)
            if~isempty(get_param(obj.handle,'ModelFile'))
                schema.state='Enabled';
            end
        elseif~SLStudio.Utils.objectIsValidModelReferenceBlock(obj)
            schema.state='Hidden';
        end
    else
        schema.state='Hidden';
    end

    schema.callback=@FindReferencedVariablesInRefMdlCB;

    schema.autoDisableWhen='Never';
end

function FindReferencedVariablesInRefMdlCB(cbinfo)
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);



    assert(~isempty(obj)&&...
    SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(obj));


    modelName=get_param(obj.handle,'ModelName');
    try
        open_system(modelName);
    catch


        return;
    end

    slprivate('findVarsDoMESearch',modelName);
end

function schema=BusEditor(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:BusEditor';
    schema.label=DAStudio.message('Simulink:studio:BusEditor');
    schema.state='Enabled';
    schema.callback=@BusEditorCB;

    schema.autoDisableWhen='Busy';
end

function BusEditorCB(cbinfo)
    if~isempty(cbinfo.model.DataDictionary)
        buseditor('Create','',Simulink.data.DataDictionary(...
        cbinfo.model.DataDictionary,'SubdictionaryErrorAction','warn'));
    else
        buseditor;
    end
end

function schema=LookupTableEditor(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:LUTEditor';
    schema.label=DAStudio.message('Simulink:studio:LUTEditor');
    schema.state='Enabled';
    schema.callback=@LookupTableEditorCB;

    schema.autoDisableWhen='Busy';
end

function LookupTableEditorCB(cbinfo)
    if(isempty(cbinfo.getSelection))
        sltbledit('Create',cbinfo.editorModel.handle);
    else
        sltbledit('Create',cbinfo.getSelection.handle);
    end
end


