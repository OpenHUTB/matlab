function schema=DiagramMenu(fncname,cbinfo,eventData)




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

function result=loc_IsSubsystemOrModelReferenceBlock(block)
    result=SLStudio.Utils.objectIsValidSubsystemBlock(block)||...
    SLStudio.Utils.objectIsValidModelReferenceBlock(block);
end

function result=loc_HasValidStateOwnerBlock(block)
    isStateReaderWriterBlock=((strcmp(get_param(block.getFullPathName,'BlockType'),'StateReader')||...
    strcmp(get_param(block.getFullPathName,'BlockType'),'StateWriter')));
    result=false;
    if(isStateReaderWriterBlock)
        stateOwnerBlock=get_param(block.getFullPathName,'StateOwnerBlock');
        blockDoesNotExist=false;
        try get_param(stateOwnerBlock,'handle');catch e;blockDoesNotExist=true;end;%#ok
        if(~blockDoesNotExist)
            result=true;
        end
    end

end

function stateReaderBlockHandles=loc_HasStateReaderBlocks(blkHandle)
    model=bdroot(blkHandle);
    stateReaderBlockHandles=[];
    if(get_param(blkHandle,'IsStateOwnerBlock'))
        stateAccessorMap=get_param(model,'StateAccessorInfoMap');

        for i=1:length(stateAccessorMap)
            if(stateAccessorMap(i).StateOwnerBlock==blkHandle)
                stateReaderBlockHandles=stateAccessorMap(i).StateReaderBlockSet;
            end
        end
    end
    stateReaderBlockHandles=sort(stateReaderBlockHandles);
end

function stateWriterBlockHandles=loc_HasStateWriterBlocks(blkHandle)
    model=bdroot(blkHandle);
    stateWriterBlockHandles=[];

    if(get_param(blkHandle,'IsStateOwnerBlock'))
        stateAccessorMap=get_param(model,'StateAccessorInfoMap');

        for i=1:length(stateAccessorMap)
            if(stateAccessorMap(i).StateOwnerBlock==blkHandle)
                stateWriterBlockHandles=stateAccessorMap(i).StateWriterBlockSet;
            end
        end
    end
    stateWriterBlockHandles=sort(stateWriterBlockHandles);
end

function schema=SubsystemAndModelRefMenuDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:SubsystemAndModelRefMenu';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:SubsystemAndModelRefMenu');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=NavigateToStateOwnerBlock(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateToStateOwnerBlock';
    schema.label=DAStudio.message('Simulink:studio:NavigateToStateOwnerBlock');

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if(~loc_HasValidStateOwnerBlock(block))
        schema.state='Hidden';
    else
        schema.callback=@NavigateToStateOwnerBlockCB;
    end
end

function NavigateToStateOwnerBlockCB(cbinfo)
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    blockHandle=target.handle;
    blockType=get_param(blockHandle,'BlockType');
    assert(strcmp(blockType,'StateReader')||strcmp(blockType,'StateWriter'));
    stateOwnerBlock=get_param(blockHandle,'StateOwnerBlock');
    hilite_system(stateOwnerBlock,'find');
end

function schema=NavigateToStateReaderBlocks(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:NavigateToStateReaderBlocks';
    schema.label=DAStudio.message('Simulink:studio:NavigateToStateReaderBlocks');

    schema.autoDisableWhen='Never';

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    stateReaderBlockHandles=loc_HasStateReaderBlocks(block.handle);
    if(isempty(stateReaderBlockHandles))
        schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
        schema.state='Hidden';
    else
        numStateReaderBlocks=length(stateReaderBlockHandles);
        childrenFcns=cell(numStateReaderBlocks,1);
        for index=1:numStateReaderBlocks
            BlkName=get_param(stateReaderBlockHandles(index),'Name');
            fullPathName=[get_param(stateReaderBlockHandles(index),'Parent'),'/',BlkName];
            childrenFcns{index}={@AddStateReaderBlockMember,...
            {index,fullPathName,stateReaderBlockHandles(index)}};
        end
        schema.childrenFcns=childrenFcns;
    end
end

function schema=AddStateReaderBlockMember(cbinfo)
    mIndex=cbinfo.userdata{1};
    mName=cbinfo.userdata{2};
    blockH=cbinfo.userdata{3};
    schema=sl_action_schema;
    schema.label=mName;
    schema.tag=['Simulink:StateReaderBlockMember_',num2str(mIndex)];
    schema.userdata=blockH;
    schema.callback=@NavigateToStateReaderBlockCB;
    schema.autoDisableWhen='Never';
end

function NavigateToStateReaderBlockCB(cbinfo)
    blockH=cbinfo.userdata;

    if ishandle(blockH)
        blockType=get_param(blockH,'BlockType');
        assert(strcmp(blockType,'StateReader'));
        hilite_system(blockH,'find');
    else
        assert(0);
    end
end

function schema=NavigateToStateWriterBlocks(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:NavigateToStateWriterBlocks';
    schema.label=DAStudio.message('Simulink:studio:NavigateToStateWriterBlocks');
    schema.autoDisableWhen='Never';

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    stateWriterBlockHandles=loc_HasStateWriterBlocks(block.handle);
    if(isempty(stateWriterBlockHandles))
        schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
        schema.state='Hidden';
    else
        numStateWriterBlocks=length(stateWriterBlockHandles);
        childrenFcns=cell(numStateWriterBlocks,1);
        for index=1:numStateWriterBlocks
            BlkName=get_param(stateWriterBlockHandles(index),'Name');
            fullPathName=[get_param(stateWriterBlockHandles(index),'Parent'),'/',BlkName];
            childrenFcns{index}={@AddStateWriterBlockMember,...
            {index,fullPathName,stateWriterBlockHandles(index)}};
        end
        schema.childrenFcns=childrenFcns;
    end
end

function schema=AddStateWriterBlockMember(cbinfo)
    mIndex=cbinfo.userdata{1};
    mName=cbinfo.userdata{2};
    blockH=cbinfo.userdata{3};
    schema=sl_action_schema;
    schema.label=mName;
    schema.tag=['Simulink:StateWriterBlockMember_',num2str(mIndex)];
    schema.userdata=blockH;
    schema.callback=@NavigateToStateWriterBlockCB;
    schema.autoDisableWhen='Never';
end

function NavigateToStateWriterBlockCB(cbinfo)
    blockH=cbinfo.userdata;

    if ishandle(blockH)
        blockType=get_param(blockH,'BlockType');
        assert(strcmp(blockType,'StateWriter'));
        hilite_system(blockH,'find');
    else
        assert(0);
    end
end


function schema=SubsystemAndModelRefMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:SubsystemAndModelRefMenu';
    schema.label=DAStudio.message('Simulink:studio:SubsystemAndModelRefMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:CreateSubsystemFromSelection')};
    schema.childrenFcns{end+1}=im.getAction('Simulink:ExpandSubsystem');
    schema.childrenFcns{end+1}=im.getSubmenu('Simulink:ConvertTo');

    if(cbinfo.isMenuBar)
        schema.childrenFcns{end+1}='separator';
    end

    schema.childrenFcns{end+1}=im.getAction('Simulink:ModelBlockNormalModeVisibility');
    schema.childrenFcns{end+1}=im.getAction('Simulink:RefreshModelReference');
    if slfeature('ProtectedModelRemoveSimulinkCoderCheck')||...
        slfeature('ProtectedModelWithGeneratedHDLCode')&&dig.isProductInstalled('HDL Coder')
        schema.childrenFcns{end+1}=im.getAction('Simulink:CreateProtectedModel');
    else
        schema.childrenFcns{end+1}=im.getAction('Simulink:GenProtectedModel');
    end

    schema.childrenFcns{end+1}='separator';
    schema.childrenFcns{end+1}=im.getAction('Simulink:UnlockProtectedModel');
    schema.childrenFcns{end+1}=im.getAction('Simulink:DisplayProtectedModelWebview');
    schema.childrenFcns{end+1}=im.getAction('Simulink:DisplayProtectedModelReport');
    schema.childrenFcns{end+1}=im.getAction('Simulink:CreateHarnessForProtectedModel');

    if(cbinfo.isContextMenu)
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if(~loc_IsSubsystemOrModelReferenceBlock(block))
            schema.state='Hidden';
        end
    end

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)&&...
        (Simulink.harness.internal.isHarnessCUT(block.handle)||strcmp(get_param(block.handle,'IsInjectorSS'),'on'))
        schema.state='Disabled';
    end

end


function schema=CreateSubsystemFromSelection(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:CreateSubsystemFromSelection';
    schema.obsoleteTags={'Simulink:CreateSubsystem'};

    selectedItem=SLStudio.Utils.getSingleSelection(cbinfo);
    isAreaCreateSubystem=SLStudio.Utils.objectIsValidArea(selectedItem);
    isComposition=Simulink.internal.isArchitectureModel(cbinfo,'Architecture')||...
    Simulink.internal.isArchitectureModel(cbinfo,'SoftwareArchitecture');

    if isComposition
        schema.label=DAStudio.message('SystemArchitecture:studio:CreateComponentFromSelection');
    elseif(isAreaCreateSubystem)
        schema.label=DAStudio.message('Simulink:studio:CreateSubsystemFromArea');
    else
        schema.label=DAStudio.message('Simulink:studio:CreateSubsystemFromSelection');
    end

    if(SLStudio.Utils.selectionHasBlocks(cbinfo)||isAreaCreateSubystem)&&~SLStudio.Utils.isLockedSystem(cbinfo)...
        &&~cbinfo.studio.App.hasSpotlightView()&&...
        ~Simulink.internal.isArchitectureModel(cbinfo,'AUTOSARArchitecture')
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    if(isAreaCreateSubystem)
        schema.callback=@CreateSubsystemFromAreaCB;
    else
        schema.callback=@CreateSubsystemCB;
    end
end

function CreateSubsystemCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    cbinfo.domain.createSubsystem(editor,cbinfo.selection);
end

function CreateSubsystemFromAreaCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    selectedItem=SLStudio.Utils.getSingleSelection(cbinfo);
    cbinfo.domain.createSubsystemFromArea(editor,selectedItem);
end

function schema=ExpandSubsystem(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ExpandSubsystem';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:expandActionLabel';
        schema.icon='expandSubsystem';
    else
        schema.label=DAStudio.message('Simulink:studio:ExpandSubsystem');
    end
    if loc_getExpandSubsystemEnabled(cbinfo)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.callback=@ExpandSubsystemCB;
end

function result=loc_getExpandSubsystemEnabled(cbinfo)
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    result=~SLStudio.Utils.isLockedSystem(cbinfo)...
    &&SLStudio.Utils.objectIsValidBlock(target)...
    &&cbinfo.domain.isExpandSubsystemMenuItemEnabled(target);
    if~isempty(target)&&...
        SLStudio.Utils.objectIsValidBlock(target)
        block=target.handle;
        isVariantSubsystem=strcmpi(get_param(block,'BlockType'),'Subsystem')&&...
        strcmpi(get_param(block,'Variant'),'on');
        if strcmpi(get_param(block,'Type'),'block')&&...
            (strcmp(get_param(block,'Mask'),'on')||...
            (strcmp(get_param(block,'Commented'),'on')&&~isVariantSubsystem)||...
            any(strcmpi(get_param(block,'LinkStatus'),...
            {'resolved','implicit'})))



            return;
        end



        if SLStudio.Utils.objectIsValidBlock(target)
            result=result&&cbinfo.domain.canExpandSubsystem(target);
        end
    end
end

function ExpandSubsystemCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    cbinfo.domain.expandSubsystem(editor,SLStudio.Utils.getOneMenuTarget(cbinfo));
end


function schema=CreateProtectedModel(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:CreateProtectedModel';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:CreateProtectedModel');
    end
    schema.state='Disabled';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if cbinfo.isContextMenu&&...
        ~SLStudio.Utils.objectIsValidModelReferenceBlock(block)
        schema.state='Hidden';
    else
        schema.state='Disabled';
    end
    if cbinfo.domain.isBdInEditMode(cbinfo.model.handle)&&...
        SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(block)
        schema.state='Enabled';
    end
    schema.callback=@CreateProtectedModelCB;
end

function state=loc_getConvertSubsystemToReferencedModelState(cbinfo)
    state='Disabled';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        blockH=get_param(block.getFullPathName,'Handle');
        if Simulink.harness.internal.isHarnessCUT(blockH)
            return;
        end


        variant=get_param(blockH,'Variant');
        if~strcmp(variant,'on')
            state='Enabled';
        end

    elseif cbinfo.isContextMenu
        state='Hidden';
    end
end

function schema=ConvertSubsystemToReferencedModel(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ConvertSubsystemToReferencedModel';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:convertToReferencedModelActionLabel';
        schema.icon='convertSubsystemToReferencedModel';
    else
        schema.label=DAStudio.message('Simulink:studio:ConvertSubsystemToReferencedModel');
    end
    schema.obsoleteTags={'Simulink:SSToMdlRef'};
    schema.state=loc_getConvertSubsystemToReferencedModelState(cbinfo);

    schema.callback=@ConvertSubsystemToReferencedModelCB;
end

function ConvertSubsystemToReferencedModelCB(cbinfo)
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(target)
        Simulink.ModelReference.mdlrefadvisor(target.getFullPathName);
    end
end




function state=loc_getConvertSubsystemToSubsystemReferenceState(cbinfo)
    state='Hidden';

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end
    if~strcmp(get_param(block.handle,'BlockType'),'SubSystem')
        return;
    end

    state='Disabled';
    [convertible,~]=SSRefUtil.passesBlockTypeCheckForConversion(block.handle);
    if convertible
        state='Enabled';
    end
end

function schema=ConvertSubsystemToSubsystemReference(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ConvertSubsystemToSubsystemReference';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:convertToSubsystemReferenceActionLabel';
        schema.icon='convertSubsystemToSubsystemReference';
    else
        schema.label=DAStudio.message('Simulink:studio:ConvertSubsystemToReferencedSubsystem');
    end

    schema.state=loc_getConvertSubsystemToSubsystemReferenceState(cbinfo);
    schema.callback=@ConvertSubsystemToSubsystemReferenceCB;
end

function ConvertSubsystemToSubsystemReferenceCB(cbinfo)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    dlgHandle=SSRefConversionDialog.createDialog(block.handle,[]);
    dlgHandle.show();
end


function schema=ModelBlockNormalModeVisibility(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ModelBlockNormalModeVisibility';
    schema.label=DAStudio.message('Simulink:studio:ModelBlockNormalModeVisibility');

    if(cbinfo.isContextMenu)
        schema.state='Hidden';
    end



    if~cbinfo.domain.isBdInEditMode(cbinfo.model.handle)

        schema.state='Disabled';
    end
    schema.callback=@ModelBlockNormalModeVisibilityCB;
end

function ModelBlockNormalModeVisibilityCB(cbinfo)
    Simulink.ModelReference.NormalModeVisibility(cbinfo.model.Name);
end
function state=loc_getRefreshModelReferenceState(cbinfo)
    state='Disabled';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            is_protected=get_param(block.handle,'ProtectedModel');
            if is_protected
                mdlrefname=get_param(block.handle,'ModelFile');

                [~,mdlrefname]=fileparts(mdlrefname);
            else
                mdlrefname=get_param(block.handle,'ModelName');
            end
            if~strcmpi(mdlrefname,slInternal('getModelRefDefaultModelName'))
                state='Enabled';
            end
        elseif cbinfo.isContextMenu
            state='Hidden';
        end
    end


    if~cbinfo.domain.isBdInEditMode(cbinfo.model.handle)&&...
        strcmpi(state,'Enabled')
        state='Disabled';
    end
end

function schema=RefreshModelReference(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RefreshModelReference';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='referencedModelRefresh';
    else
        schema.label=DAStudio.message('Simulink:studio:RefreshModelReference');
    end
    schema.state=loc_getRefreshModelReferenceState(cbinfo);
    schema.callback=@RefreshModelReferenceCB;
    schema.autoDisableWhen='Busy';
end

function RefreshModelReferenceCB(cbinfo)
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidModelReferenceBlock(target)
        obj=get_param(target.handle,'Object');
        try
            obj.refreshModelBlock;
        catch me
            sldiagviewer.reportError(me.message,'MessageId',me.identifier);
        end
    end
end


function schema=RotateClockwise(cbinfo)%#ok<DEFNU>
    if UseGroup(cbinfo)
        schema=RotateGroupClockwise(cbinfo);
    else
        schema=sl_action_schema;
        schema.tag='Simulink:RotateClockwise';
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:RotateClockwise');
            schema.icon='Simulink:RotateClockwise';
        else
            schema.icon='rotateCW';
        end
        schema.userdata='clockwise';
        if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
            schema.state='Disabled';
        end
        schema.obsoleteTags={'Simulink:RotateBlock:Clockwise'};
        schema.callback=@RotateBlocksCB;
    end
end

function schema=RotateGroupClockwise(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:RotateClockwise';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:RotateGroupClockwise');
        schema.icon='Simulink:RotateClockwise';
    else
        schema.icon='rotateCW';
    end
    schema.userdata='group-clockwise';
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    end

    schema.callback=@RotateGroupCB;
end

function schema=RotateCounterClockwise(cbinfo)%#ok<DEFNU>
    if UseGroup(cbinfo)
        schema=RotateGroupCounterClockwise(cbinfo);
    else
        schema=sl_action_schema;
        schema.tag='Simulink:RotateCounterClockwise';
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:RotateCounterClockwise');
            schema.icon='Simulink:RotateCounterClockwise';
        else
            schema.icon='rotateCCW';
        end
        schema.userdata='counterclockwise';
        if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
            schema.state='Disabled';
        end
        schema.obsoleteTags={'Simulink:RotateBlock:CounterClockwise'};
        schema.callback=@RotateBlocksCB;
    end
end

function schema=RotateGroupCounterClockwise(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:RotateCounterClockwise';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:RotateGroupCounterClockwise');
        schema.icon='Simulink:RotateCounterClockwise';
    else
        schema.icon='rotateCCW';
    end
    schema.userdata='group-counterclockwise';
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    end

    schema.callback=@RotateGroupCB;
end


function useGroup=UseGroup(cbinfo)
    useGroup=false;
    if slfeature('SLGroupRotation')~=0
        selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        if numel(selectedBlockHandles)>1
            useGroup=true;
        end
        if numel(selectedBlockHandles)==1
            areas=SLStudio.Utils.getSelectedAreaAnnotationHandles(cbinfo);
            if numel(areas)>0
                useGroup=true;
            end
        end
    end
end


function RotateBlocksCB(cbinfo)
    handles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if~isempty(handles)
        editor=cbinfo.studio.App.getActiveEditor;
        rotateDirection=cbinfo.userdata;

        undoId='Simulink:studio:RotateBlocksCommand';
        undoStr=DAStudio.message(undoId);
        editor.createMCommand(undoId,undoStr,@rotate_blocks,{handles,rotateDirection});
    end
end


function RotateGroupCB(cbinfo)
    blocks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if~isempty(blocks)
        areas=SLStudio.Utils.getSelectedAreaAnnotationHandles(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        rotateDirection=cbinfo.userdata;
        undoId='Simulink:studio:RotateGroupCommand';
        undoStr=DAStudio.message(undoId);
        cust=GLUE2.CommandCustomizations;
        cust.animationParams.animateOnDo=true;
        cust.animationParams.actorType='EasedActor';
        cust.restoreSelectionOnUndo=true;
        cust.restoreSelectionOnRedo=true;
        editor.createMCommandWithCustomizations(cust,undoId,undoStr,@rotate_group,{blocks,rotateDirection,areas});
    end
end

function onlyPhysicalRTs=loc_isOnlyPhysicalRTs(blockHandles)
    onlyPhysicalRTs=false;
    numSelBlocks=length(blockHandles);
    if(numSelBlocks>0)
        onlyPhysicalRTs=true;
        for i=1:numSelBlocks
            portRotationType=get_param(blockHandles(i),'PortRotationType');
            if~strcmpi('physical',portRotationType)
                onlyPhysicalRTs=false;
                break
            end
        end
    end
end

function schemas=GetFlipBlockItems(cbinfo,useGroup)
    if useGroup
        schemas={@FlipGroupLR};
    else
        selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        onlyPhysicalRTs=loc_isOnlyPhysicalRTs(selectedBlockHandles);
        if onlyPhysicalRTs
            schemas={@FlipBlockPhysicalMenu};
        else
            schemas={@FlipBlockLR};
        end
    end
end

function schema=FlipBlockLR(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FlipBlockLR';
    schema.icon='Simulink:FlipBlockLR';
    schema.label=DAStudio.message('Simulink:studio:FlipBlock');
    schema.userdata='default';

    selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if isempty(selectedBlockHandles)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
        schema.callback=@FlipBlocksCB;
    end
end

function schema=FlipBlockPhysicalMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:FlipBlockPhysicalMenu';
    schema.label=DAStudio.message('Simulink:studio:FlipBlockPhysicalMenu');

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    schema.childrenFcns={@FlipBlockPhysicalLR,...
    @FlipBlockPhysicalUD
    };
end

function schema=FlipBlockPhysicalLR(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FlipBlockLR';
    schema.icon='Simulink:FlipBlockLR';
    schema.label=DAStudio.message('Simulink:studio:FlipBlockPhysicalLR');
    schema.userdata='left-right';

    selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if isempty(selectedBlockHandles)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
        schema.callback=@FlipBlocksCB;
    end
end

function schema=FlipGroupLR(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FlipBlockLR';
    schema.icon='Simulink:FlipBlockLR';
    schema.label=DAStudio.message('Simulink:studio:FlipGroupLR');
    schema.userdata='group-left-right';

    selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if isempty(selectedBlockHandles)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
        schema.callback=@FlipGroupCB;
    end
end

function schema=FlipBlockPhysicalUD(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FlipBlockUD';

    schema.label=DAStudio.message('Simulink:studio:FlipBlockPhysicalUD');
    schema.userdata='up-down';

    selectedBlockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if isempty(selectedBlockHandles)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
        schema.callback=@FlipBlocksCB;
    end
end

function FlipBlocksCB(cbinfo)
    handles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if UseGroup(cbinfo)
        cbinfo.userdata='group-left-right';
        FlipGroupCB(cbinfo);
    else
        rotate_type=cbinfo.userdata;
        if~isempty(handles)
            editor=cbinfo.studio.App.getActiveEditor;
            undoId='Simulink:studio:FlipBlocksCommand';
            undoStr=DAStudio.message(undoId);
            if strcmpi(rotate_type,'default')
                editor.createMCommand(undoId,undoStr,@flip_blocks,{handles});
            else
                editor.createMCommand(undoId,undoStr,@flip_blocks,{handles,rotate_type});
            end
        end
    end
end

function FlipGroupCB(cbinfo)
    blocks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    rotate_type=cbinfo.userdata;
    if~isempty(blocks)
        annotations=SLStudio.Utils.getSelectedAreaAnnotationHandles(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        undoId='Simulink:studio:FlipGroupCommand';
        undoStr=DAStudio.message(undoId);
        cust=GLUE2.CommandCustomizations;
        cust.animationParams.animateOnDo=true;
        cust.animationParams.actorType='EasedActor';
        cust.restoreSelectionOnUndo=true;
        cust.restoreSelectionOnRedo=true;
        editor.createMCommandWithCustomizations(cust,undoId,undoStr,@flip_group,{blocks,rotate_type,annotations});
    end
end

function schema=FlipBlockName(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:FlipBlockName';
    schema.label=DAStudio.message('Simulink:studio:FlipBlockName');
    schema.icon='Simulink:FlipBlockName';
    schema.userdata=schema.tag;
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isParentArchitectureDomain(cbinfo)
        schema.state='Disabled';
    end
    schema.obsoleteTags={'Simulink:FlipName'};
    schema.callback=@FlipBlocksNameCB;
end

function FlipBlocksNameCB(cbinfo)
    handles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    if~isempty(handles)
        editor=cbinfo.studio.App.getActiveEditor;
        undoId='Simulink:studio:FlipBlockNameCommand';
        undoStr=DAStudio.message(undoId);
        editor.createMCommand(undoId,undoStr,@SLStudio.Utils.flip_blocks_name,{handles});
    end
end

function res=loc_areOnlyConnectionLinesSelected(cbinfo)
    res=false;
    selected=cbinfo.getSelection();
    if~isempty(selected)
        res=true;
        for j=1:length(selected)
            sel=selected(j);
            if~strcmpi(sel.Type,'line')||...
                ~strcmpi(get_param(sel.Handle,'LineType'),'connection')
                res=false;
                break
            end
        end
    end
end

function state=loc_getFormatMenuState(cbinfo)
    if~SLStudio.Utils.isLockedSystem(cbinfo)&&...
        ~loc_areOnlyConnectionLinesSelected(cbinfo)
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=FormatMenuDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:FormatMenu';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:FormatMenu');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=FormatMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:FormatMenu';
    schema.label=DAStudio.message('Simulink:studio:FormatMenu');
    schema.state=loc_getFormatMenuState(cbinfo);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    showShortMenu=false;
    if Simulink.internal.isParentArchitectureDomain(cbinfo)





        blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
        for i=1:numel(blocks)
            block=blocks(i);
            if((SLStudio.Utils.objectIsValidSubsystemBlock(block)...
                &&~strcmp(get_param(block.handle,'SimulinkSubDomain'),'ArchitectureAdapter'))...
                ||SLStudio.Utils.objectIsValidModelReferenceBlock(block))
                showShortMenu=true;
                break;
            end
        end
    end

    childrenFcns={im.getAction('Simulink:AutoLayoutDiagram')};
    if showShortMenu
        childrenFcns=[childrenFcns...
        ,{...
        'separator',...
        im.getAction('Simulink:ContentPreview'),...
        im.getAction('Simulink:BlockFitToContent'),...
'separator'
        }];
    else
        flip_block_menu=GetFlipBlockItems(cbinfo,UseGroup(cbinfo));
        show_name_menu=im.getSubmenu('Simulink:ShowBlockNameMenu');

        childrenFcns=[childrenFcns...
        ,{...
        im.getAction('Simulink:AlignPorts'),...
        im.getAction('Stateflow:DiagramFormatting'),...
        'separator',...
        show_name_menu,...
        'separator',...
        im.getSubmenu('Simulink:TextAlignmentMenu'),...
        im.getAction('Simulink:LatexMode'),...
        im.getAction('Simulink:MathMLMode'),...
        'separator',...
        im.getSubmenu('Simulink:ForegroundColorMenu'),...
        im.getSubmenu('Simulink:BackgroundColorMenu'),...
        im.getSubmenu('Simulink:CanvasColorMenu'),...
        im.getSubmenu('Simulink:ConnectorWidthMenu'),...
        'separator',...
        im.getAction('Simulink:RotateClockwise'),...
        im.getAction('Simulink:RotateCounterClockwise'),...
        flip_block_menu{1},...
        im.getAction('Simulink:FlipBlockName'),...
        'separator',...
        im.getAction('Simulink:ContentPreview'),...
        im.getAction('Simulink:BlockFitToContent'),...
        im.getSubmenu('Simulink:PortLabelsMenu'),...
'separator'
        }];
    end

    childrenFcns=[childrenFcns...
    ,{...
    im.getAction('Simulink:AlignLeftEdges'),...
    im.getAction('Simulink:AlignCentersVertically'),...
    im.getAction('Simulink:AlignRightEdges'),...
    'separator',...
    im.getAction('Simulink:AlignTopEdges'),...
    im.getAction('Simulink:AlignCentersHorizontally'),...
    im.getAction('Simulink:AlignBottomEdges'),...
    'separator',...
    im.getAction('Simulink:BringToFront'),...
    im.getAction('Simulink:SendToBack')
    }];

    schema.childrenFcns=childrenFcns;
end

function schema=Font(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:Font';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='fontProperties';
    else
        schema.label=DAStudio.message('Simulink:studio:SelectionFont');
    end
    parts=SLStudio.Utils.partitionSelection(cbinfo);
    numNoFont=numel(parts.connectors)+numel(parts.markupConnectors)+numel(parts.markupItems);





    if cbinfo.selection.size==0||...
        cbinfo.selection.size==numNoFont||...
        loc_isImage(cbinfo)||...
        SLStudio.Utils.isPanelWebBlock(cbinfo)
        schema.state='Disabled';
    end
    schema.callback=@FontCB;
end

function result=fontEqual(font0,font1)
    if(~strcmpi(font0.Family,font1.Family))
        result=0;
        return;
    end

    if(~strcmpi(font0.Weight,font1.Weight))
        result=0;
        return;
    end
    if(~strcmpi(font0.Style,font1.Style))
        result=0;
        return;
    end
    if(font0.Size~=font1.Size)
        result=0;
        return;
    end

    result=1;
end

function result=isConnector(target)
    result=strcmp(target.MetaClass.qualifiedName,'SLM3I.Connector')||...
    strcmp(target.MetaClass.qualifiedName,'markupM3I.Connector');
end

function FontCB(cbinfo)
    parts=SLStudio.Utils.partitionSelection(cbinfo);
    editor=cbinfo.studio.App.getActiveEditor;
    target=GLUE2.DiagramElement;%#ok<NASGU>

    if(cbinfo.isContextMenu)
        target=cbinfo.target;
    else
        target=editor.getPrimarySelection();
        if(~target.isvalid)
            target=editor.getSelection().at(1);
        end
    end
    if(strcmp(target.MetaClass.qualifiedName,'SLM3I.Segment')||...
        strcmp(target.MetaClass.qualifiedName,'SLM3I.SolderJoint')||...
        strcmp(target.MetaClass.qualifiedName,'SLM3I.Port'))
        target=target.container;
    end

    if(isConnector(target))


        for idx=1:editor.getSelection().size
            target=editor.getSelection().at(idx);
            if~(isConnector(target))
                break;
            end
        end
    end

    font=target.font;

    fontName=MG2.Font.getClosestFontName(font.Family);
    font.Family=fontName;

    newFont=GLUE2.Util.invokeFontPicker(font);

    if(newFont.isValid)


        undoId='Simulink:studio:SetFont';
        undoStr=DAStudio.message(undoId);
        editor.createMCommand(undoId,undoStr,@set_font,{newFont,parts});
    end
end

function set_font(font,parts)
    for i=1:length(parts.blocks)
        b=parts.blocks(i);
        m=M3I.ImmutableModel.cast(b.modelM3I.getRootDeviant);
        b=b.asDeviant(m);
        if~fontEqual(b.font,font)
            b.font=font;
        end
    end
    for i=1:length(parts.notes)
        n=parts.notes(i);
        m=M3I.ImmutableModel.cast(n.modelM3I.getRootDeviant);
        n=n.asDeviant(m);
        if~fontEqual(n.font,font)
            n.font=font;
        end
    end
    for i=1:length(parts.segments)
        l=parts.segments(i).container;
        m=M3I.ImmutableModel.cast(l.modelM3I.getRootDeviant);
        l=l.asDeviant(m);
        if~fontEqual(l.font,font)
            l.font=font;
        end
    end
end


function schema=DefaultFonts(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DefaultFonts';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='fontStyleForModel';
    elseif bdIsLibrary(bdroot(SLStudio.Utils.getDiagramHandle(cbinfo)))
        schema.label=DAStudio.message('Simulink:studio:LibraryFont');
    else
        schema.label=DAStudio.message('Simulink:studio:ModelFont');
    end
    schema.callback=@DefaultFontsCB;
end

function DefaultFontsCB(cbinfo)
    bd=bdroot(SLStudio.Utils.getDiagramHandle(cbinfo));
    DAStudio.Dialog(Simulink.FontPrefs(bd));
end

function state=loc_getTextAlignmentMenuState(cbinfo)
    state='Enabled';
    if SLStudio.Utils.isLockedSystem(cbinfo)
        state='Disabled';
    end
    if isempty(SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo))
        if cbinfo.isContextMenu
            state='Hidden';
        else
            state='Disabled';
        end
    end
end

function schema=TextAlignmentMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:TextAlignmentMenu';
    schema.label=DAStudio.message('Simulink:studio:TextAlignmentMenu');

    schema.state=loc_getTextAlignmentMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:TextAlignLeft'),...
    im.getAction('Simulink:TextAlignCenter'),...
    im.getAction('Simulink:TextAlignRight')
    };
end

function checked=loc_TextAlignmentCheck(cbinfo,alignment)
    checked='Unchecked';
    noteHandles=SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo);
    for i=1:length(noteHandles)
        note=noteHandles(i);
        if strcmp(get_param(note,'HorizontalAlignment'),alignment)
            checked='Checked';
            break;
        end
    end
end

function schema=TextAlignLeft(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:TextAlignLeft';
    schema.label=DAStudio.message('Simulink:studio:TextAlignLeft');
    schema.state=loc_getTextAlignmentMenuState(cbinfo);
    schema.checked=loc_TextAlignmentCheck(cbinfo,'left');
    schema.obsoleteTags={'Simulink:AlignmentHorizontalLeft'};
    schema.userdata='left';
    schema.callback=@SetTextAlignmentCB;
end

function schema=TextAlignCenter(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:TextAlignCenter';
    schema.label=DAStudio.message('Simulink:studio:TextAlignCenter');
    schema.state=loc_getTextAlignmentMenuState(cbinfo);
    schema.checked=loc_TextAlignmentCheck(cbinfo,'center');
    schema.obsoleteTags={'Simulink:AlignmentHorizontalCenter'};
    schema.userdata='center';
    schema.callback=@SetTextAlignmentCB;
end

function schema=TextAlignRight(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:TextAlignRight';
    schema.label=DAStudio.message('Simulink:studio:TextAlignRight');
    schema.state=loc_getTextAlignmentMenuState(cbinfo);
    schema.checked=loc_TextAlignmentCheck(cbinfo,'right');
    schema.obsoleteTags={'Simulink:AlignmentHorizontalRight'};
    schema.userdata='right';
    schema.callback=@SetTextAlignmentCB;
end

function loc_setTextAlignment(notes,alignment)
    for i=1:length(notes)
        noteHandle=notes(i);
        sl('setAnnotationAlignment',noteHandle,alignment);
    end
end

function SetTextAlignmentCB(cbinfo)
    alignment=cbinfo.userdata;
    noteHandles=SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo);

    editor=cbinfo.studio.App.getActiveEditor;

    undoId='Simulink:studio:SLChangeAlignment';
    undoStr=DAStudio.message(undoId);
    editor.createMCommand(undoId,undoStr,@loc_setTextAlignment,{noteHandles,alignment});
end

function checked=loc_InterpreterModeCheck(cbinfo,mode)
    attribute_count=0;
    noteHandles=SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo);
    for i=1:length(noteHandles)
        note=noteHandles(i);
        if strcmp(get_param(note,'Interpreter'),mode)
            attribute_count=attribute_count+1;
        else
            attribute_count=attribute_count-1;
        end
    end
    if attribute_count>0
        checked='Checked';
    else
        checked='Unchecked';
    end
end

function schema=LatexMode(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LatexMode';
    schema.label=DAStudio.message('Simulink:studio:LatexMode');

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if isempty(SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo))
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    else
        schema.checked=loc_InterpreterModeCheck(cbinfo,'tex');
        undoStr=DAStudio.message('Simulink:studio:LatexModeCommand');
        if strcmp(schema.checked,'Checked')
            schema.userdata=struct('value','off','undoStr',undoStr);
        else
            schema.userdata=struct('value','tex','undoStr',undoStr);
        end
    end

    schema.callback=@InterpretModeCB;
end

function schema=MathMLMode(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:MathMLMode';
    schema.label=DAStudio.message('Simulink:studio:MathMLMode');

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if isempty(SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo))
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    else
        schema.checked=loc_InterpreterModeCheck(cbinfo,'mathml');
        undoStr=DAStudio.message('Simulink:studio:MathMLModeCommand');
        if strcmp(schema.checked,'Checked')
            schema.userdata=struct('value','off','undoStr',undoStr);
        else
            schema.userdata=struct('value','mathml','undoStr',undoStr);
        end
    end

    schema.callback=@InterpretModeCB;

    try
        MathGraphicsTextNodeFeat=slfeature('MathGraphicsTextNode')>1;
    catch
        MathGraphicsTextNodeFeat=false;
    end

    if~MathGraphicsTextNodeFeat
        schema.state='Hidden';
    end
end

function InterpretModeCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    undoStr=cbinfo.userdata.undoStr;

    editor.createMCommand(undoStr,undoStr,@InterpretModeCommand,{cbinfo});
end

function InterpretModeCommand(cbinfo)
    value=cbinfo.userdata.value;
    noteHandles=SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo);
    SLStudio.Utils.SetAnnotationParam(noteHandles,'Interpreter',value);
end

function checked=loc_ShowInLibBrowserCheck(cbinfo,mode)
    attribute_count=0;
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    for i=1:length(noteHandles)
        note=noteHandles(i);
        if strcmp(get_param(note,'ShowInLibBrowser'),mode)
            attribute_count=attribute_count+1;
        else
            attribute_count=attribute_count-1;
        end
    end
    if attribute_count>0
        checked='Checked';
    else
        checked='Unchecked';
    end
end

function schema=ShowInLibBrowser(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowInLibBrowser';
    schema.label=DAStudio.message('Simulink:studio:ShowInLibBrowser');

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end
    if isempty(SLStudio.Utils.getSelectedAnnotationHandles(cbinfo))
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    else
        schema.checked=loc_ShowInLibBrowserCheck(cbinfo,'on');
        undoStr=DAStudio.message('Simulink:studio:ShowInLibBrowser');
        if strcmp(schema.checked,'Checked')
            schema.userdata=struct('value','off','undoStr',undoStr);
        else
            schema.userdata=struct('value','on','undoStr',undoStr);
        end
    end

    schema.callback=@ShowInLibBrowserCB;
end

function ShowInLibBrowserCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    undoStr=cbinfo.userdata.undoStr;

    editor.createMCommand(undoStr,undoStr,@ShowInLibBrowserCommand,{cbinfo});
end

function ShowInLibBrowserCommand(cbinfo)
    value=cbinfo.userdata.value;
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    SLStudio.Utils.SetAnnotationParam(noteHandles,'ShowInLibBrowser',value);



    if strcmpi(value,'on')
        h=cbinfo.studio.App.blockDiagramHandle;
        if strcmpi(get_param(h,'BlockDiagramType'),'Library')
            set_param(h,'EnableLBRepository','on');
        end
    end
end

function schema=EditText(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:EditText';
    schema.label=DAStudio.message('Simulink:studio:EditText');
    schema.callback=@EditTextCB;
end

function EditTextCB(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    note=get_param(noteHandles(1),'Object');
    note.editText();
end

function schema=InsertImage(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:InsertImage';
    schema.label=DAStudio.message('Simulink:studio:InsertImage');
    schema.callback=@InsertImageCB;
end

function InsertImageCB(cbinfo)
    [filename,canceled]=uigetimagefile('MultiSelect','off');
    if~canceled
        editor=cbinfo.studio.App.getActiveEditor;
        undoId='Simulink:studio:InsertImageCommand';
        undoStr=DAStudio.message(undoId);
        editor.createMCommand(undoId,undoStr,@InsertImageCommand,{cbinfo,filename});
    end
end

function InsertImageCommand(cbinfo,filename)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    note=get_param(noteHandles(1),'Object');
    note.setImage(filename);
end

function state=loc_getValidImageState(cbinfo)
    isImage=loc_isImage(cbinfo);
    if(isImage)
        state='Enabled';
    else
        state='Disabled';
    end
end

function isImage=loc_isImage(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    isImage=true;
    if isempty(noteHandles)
        isImage=false;
    else
        for i=1:length(noteHandles)
            note=get_param(noteHandles(i),'Object');
            if(strcmp(note.isImage,'off'))
                isImage=false;
                break;
            end
        end
    end
end

function schema=CopyImage(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:CopyImage';
    schema.label=DAStudio.message('Simulink:studio:CopyImage');
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@CopyImageCB;
end

function CopyImageCB(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    note=get_param(noteHandles(1),'Object');
    filename=getResolvedResourceFile(cbinfo.model.handle,note.imagePath);
    GLUE2.Util.imageClipboard(filename,'copy');
end

function state=loc_getPasteImageState(~)
    if(GLUE2.Util.imageClipboard('','paste'))
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=PasteImage(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:PasteImage';
    schema.label=DAStudio.message('Simulink:studio:PasteImage');
    schema.state=loc_getPasteImageState(cbinfo);
    schema.callback=@PasteImageCB;
end

function PasteImageCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Simulink:studio:PasteImageCommand';
    undoStr=DAStudio.message(undoId);
    editor.createMCommand(undoId,undoStr,@PasteImageCommand,{cbinfo});
end

function PasteImageCommand(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    note=get_param(noteHandles(1),'Object');
    note.setImage('clipboard');
end

function schema=RestoreImageSize(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RestoreImageSize';
    schema.label=DAStudio.message('Simulink:studio:RestoreImageSize');
    schema.icon='Simulink:RestoreImageSize';
    schema.callback=@RestoreImageSizeCB;
end

function RestoreImageSizeCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Simulink:studio:RestoreImageSizeCommand';
    undoStr=DAStudio.message(undoId);
    editor.createMCommand(undoId,undoStr,@RestoreImageSizeCommand,{cbinfo});
end

function RestoreImageSizeCommand(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    SLStudio.Utils.SetAnnotationParam(noteHandles,'FixedHeight','off');
    SLStudio.Utils.SetAnnotationParam(noteHandles,'FixedWidth','off');
end

function schema=RotateImageRight90(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RotateImageRight90';
    schema.label=DAStudio.message('Simulink:studio:RotateImageRight90');
    schema.icon=schema.tag;
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@RotateImageCB;
    schema.userdata='RotateRight90';
end

function schema=RotateImageLeft90(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RotateImageLeft90';
    schema.label=DAStudio.message('Simulink:studio:RotateImageLeft90');
    schema.icon=schema.tag;
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@RotateImageCB;
    schema.userdata='RotateLeft90';
end

function schema=RotateImage180(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RotateImage180';
    schema.label=DAStudio.message('Simulink:studio:RotateImage180');
    schema.icon=schema.tag;
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@RotateImageCB;
    schema.userdata='Rotate180';
end

function schema=FlipImageVertical(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:FlipImageVertical';
    schema.label=DAStudio.message('Simulink:studio:FlipImageVertical');
    schema.icon=schema.tag;
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@RotateImageCB;
    schema.userdata='FlipVertical';
end

function schema=FlipImageHorizontal(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:FlipImageHorizontal';
    schema.label=DAStudio.message('Simulink:studio:FlipImageHorizontal');
    schema.icon=schema.tag;
    schema.state=loc_getValidImageState(cbinfo);
    schema.callback=@RotateImageCB;
    schema.userdata='FlipHorizontal';
end


function RotateImageCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Simulink:studio:RotateImageCommand';
    undoStr=DAStudio.message(undoId);
    editor.createMCommand(undoId,undoStr,@RotateImageCommand,{cbinfo});
end

function RotateImageCommand(cbinfo)
    rotate=cbinfo.userdata;
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);

    for i=1:length(noteHandles)
        note=get_param(noteHandles(i),'Object');
        position=note.Position;


        filename=getResolvedResourceFile(cbinfo.model.handle,note.imagePath);
        filename=GLUE2.Util.imageRotate(filename,rotate);


        note.setImage(filename);
        if strcmpi(rotate,'RotateRight90')||strcmpi(rotate,'RotateLeft90')

            center=(position(1:2)+position(3:4))/2;


            oldSize=position(3:4)-position(1:2);
            newSize=[oldSize(2),oldSize(1)];


            position(1:2)=center-newSize/2;
            position(3:4)=position(1:2)+newSize;
            set_param(noteHandles(i),'Position',position);
        end
    end
end

function value=loc_getToggleParamOfObjects(blockHandleList,param)
    attribute_count=0;


    for i=1:length(blockHandleList)
        if~strcmpi(get_param(blockHandleList(i),param),'off')
            attribute_count=attribute_count+1;
        else
            attribute_count=attribute_count-1;
        end
    end

    value=(attribute_count>0);
end

function schema=loc_applyCommonOptionsForBorderAndShadow(schema,cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if and(~SLStudio.Utils.selectionHasBlocks(cbinfo),~SLStudio.Utils.selectionHasAnnotations(cbinfo))
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    else
        checked=loc_getToggleParamOfObjects(horzcat(SLStudio.Utils.getSelectedBlockHandles(cbinfo),SLStudio.Utils.getSelectedAnnotationHandles(cbinfo)),'DropShadow');
        if checked
            schema.userdata='off';
            schema.checked='Checked';
        else
            schema.userdata='on';
            schema.checked='Unchecked';
        end
    end
end

function loc_commonCommandForBorderAndShadow(msg,msgTranslated,cbinfo)
    blockAndAnnHandles=horzcat(SLStudio.Utils.getSelectedBlockHandles(cbinfo),SLStudio.Utils.getSelectedAnnotationHandles(cbinfo));
    numObjects=length(blockAndAnnHandles);

    if(numObjects>0)
        editor=cbinfo.studio.App.getActiveEditor;
        if(~isempty(editor))
            if slfeature('SelectiveParamUndoRedo')>0
                editorDomain=editor.getStudio.getActiveDomain();
                editorDomain.createParamChangesCommand(...
                editor,...
                msg,...
                msgTranslated,...
                @DropShadowCommand,...
                {cbinfo,editorDomain},...
                false,...
                false,...
                false,...
                true,...
                true);
            else
                editor.createMCommand(msg,msgTranslated,@DropShadowCommandNoUndoFeature,{cbinfo,[]});
            end
        end
    end
end

function BorderCB(cbinfo)
    loc_commonCommandForBorderAndShadow('Simulink:studio:AreaBorder',DAStudio.message('Simulink:studio:AreaBorder'),cbinfo);
end

function DropShadowCB(cbinfo,~)
    loc_commonCommandForBorderAndShadow('Simulink:studio:DropShadowCommand',DAStudio.message('Simulink:studio:DropShadowCommand'),cbinfo);
end


function schema=BorderMenuAction(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:BorderMenuAction';
    schema.label=DAStudio.message('Simulink:studio:AreaBorder');
    schema=loc_applyCommonOptionsForBorderAndShadow(schema,cbinfo);
    schema.callback=@BorderCB;
end


function schema=DropShadow(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:DropShadow';
    schema=loc_applyCommonOptionsForBorderAndShadow(schema,cbinfo);
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='shadow';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:DropShadow');
    end
    schema.callback=@DropShadowCB;
end

function[success,noop]=DropShadowCommand(cbinfo,editorDomain)
    success=true;
    noop=false;%#ok
    blockAndAnnHandles=horzcat(SLStudio.Utils.getSelectedBlockHandles(cbinfo),SLStudio.Utils.getSelectedAnnotationHandles(cbinfo));
    errObjH=[];
    numObj=length(blockAndAnnHandles);

    for index=1:numObj
        try
            objH=blockAndAnnHandles(index);
            if(~isempty(editorDomain))
                editorDomain.paramChangesCommandAddObject(objH);
            end

            set_param(objH,'DropShadow',cbinfo.userdata);
        catch
            numErrs=numErrs+1;
            errObjH(end+1)=blockAndAnnHandles(index);%#ok
        end
    end

    if~isempty(errObjH)
        message=[DAStudio.message('Simulink:studio:DropShadowUnsupported'),sprintf('\n'),sprintf('\n')];
        for index=1:length(errObjH)
            message=[message,strrep(getfullname(errObjH(index)),sprintf('\n'),' '),sprintf('\n')];%#ok
        end
        warndlg(message);
    end
    noop=length(errObjH)==numObj;
end

function DropShadowCommandNoUndoFeature(cbinfo)
    blockAndAnnHandles=horzcat(SLStudio.Utils.getSelectedBlockHandles(cbinfo),SLStudio.Utils.getSelectedAnnotationHandles(cbinfo));
    for index=1:length(blockAndAnnHandles)
        set_param(blockAndAnnHandles(index),'DropShadow',cbinfo.userdata);
    end
end

function schema=ShowBlockName(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowBlockName';
    schema.label=DAStudio.message('Simulink:studio:ShowBlockName');

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    else
        checked=loc_getToggleParamOfObjects(SLStudio.Utils.getSelectedBlockHandles(cbinfo),'ShowName');
        if checked
            schema.userdata='off';
            schema.checked='Checked';
        else
            schema.userdata='on';
            schema.checked='Unchecked';
        end
    end
    schema.obsoleteTags={'Simulink:ShowHideName'};
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('simulink_ui:studio:resources:showBlockNameActionLabel');
    end

    schema.callback=@ShowBlockNameCB;
end

function ShowBlockNameCB(cbinfo,~)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    uData=cbinfo.userdata;
    selectedBlocksSize=length(blockHandles);
    for index=1:selectedBlocksSize
        set_param(blockHandles(index),'ShowName',uData);
    end
end

function ret=ShowNameValue(blockHandle)
    if(strcmpi(get_param(blockHandle,'ShowName'),'off'))
        ret='off';
    elseif(strcmpi(get_param(blockHandle,'HideAutomaticName'),'on'))
        ret='auto';
    else
        ret='on';
    end
end
function schema=ShowBlockNameMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ShowBlockNameMenu';
    schema.label=DAStudio.message('Simulink:studio:ShowBlockName');


    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    checkedValue='';
    if(length(blockHandles)<1)
        schema.state='Disabled';
    else
        checkedValue=ShowNameValue(blockHandles(1));

        for index=2:length(blockHandles)
            if(strcmp(checkedValue,ShowNameValue(blockHandles(index)))==0)
                checkedValue='';
                break;
            end
        end
    end

    schema.childrenFcns={{@loc_ShowNameSchema,{'auto',checkedValue}},...
    {@loc_ShowNameSchema,{'on',checkedValue}},...
    {@loc_ShowNameSchema,{'off',checkedValue}}
    };
end

function schema=loc_ShowNameSchema(cbinfo)
    type=cbinfo.userdata{1};
    checked=cbinfo.userdata{2};

    schema=sl_toggle_schema;
    schema.label=DAStudio.message(['Simulink:studio:ShowBlockName_',type]);
    if strcmpi(type,checked)
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.callback=@ShowNameCB;
    schema.userdata=type;
    schema.tag=['Simulink:ShowBlockNameMenu:',type];
end

function schema=ShowNameCB(cbinfo)%#ok<STOUT>
    type=cbinfo.userdata;

    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    for index=1:length(blockHandles)
        if(strcmpi(type,'auto'))
            set_param(blockHandles(index),'HideAutomaticName','on');
            set_param(blockHandles(index),'ShowName','on');
        else
            set_param(blockHandles(index),'HideAutomaticName','off');
            set_param(blockHandles(index),'ShowName',type);
        end
    end
end


function matchingBlockHandleList=loc_getContentPreviewBlocks(cbinfo)
    matchingBlockHandleList=[];

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        return;
    end

    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    for i=1:length(blockHandles)
        blockHandle=blockHandles(i);
        blockType=get_param(blockHandle,'BlockType');
        isSubsystem=strcmp(blockType,'SubSystem');
        if isSubsystem||strcmp(blockType,'ModelReference')



            if SLM3I.SLDomain.isStateflowTruthTableBlock(blockHandle)||SLM3I.SLDomain.isStateflowTransitionTableBlock(blockHandle)||SLM3I.SLDomain.isTestSequenceBlock(blockHandle)
                continue;
            end


            if SLM3I.SLDomain.isEMLFunctionBlock(blockHandle)||SLM3I.SLDomain.isStateflowEMLFunctionBlock(blockHandle)
                continue;
            end

            if isSubsystem&&(strcmp(get_param(blockHandle,'SimulinkSubDomain'),'ArchitectureAdapter')||...
                strcmp(get_param(blockHandle,'SFBlockType'),'Requirements Table'))
                continue;
            end

            matchingBlockHandleList=[matchingBlockHandleList,blockHandle];%#ok<AGROW>
        end
    end
end

function schema=ContentPreview(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ContentPreview';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='contentPreview';
        schema.label='simulink_ui:studio:resources:contentPreviewSimulinkActionLabel';
    else
        schema.label=DAStudio.message('Simulink:studio:ContentPreview');
    end

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';
    end



    blocksWithContentPreview=loc_getContentPreviewBlocks(cbinfo);

    if~isempty(blocksWithContentPreview)



        allBlocksMasked=true;
        for block=blocksWithContentPreview
            if strcmp(get_param(block,'Mask'),'off')
                allBlocksMasked=false;
                break;
            end
        end
        if allBlocksMasked
            schema.state='Disabled';
            return;
        end

        checked=loc_getToggleParamOfObjects(blocksWithContentPreview,'ContentPreviewEnabled');
        if checked
            schema.userdata={'off',blocksWithContentPreview};
            schema.checked='Checked';
        else
            schema.userdata={'on',blocksWithContentPreview};
            schema.checked='Unchecked';
        end
    else
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
        schema.checked='Unchecked';
    end
    schema.callback=@ContentPreviewCB;
end

function ContentPreviewCB(cbinfo,~)
    setValue=cbinfo.userdata{1};
    blocksWithContentPreview=cbinfo.userdata{2};
    for index=1:length(blocksWithContentPreview)
        set_param(blocksWithContentPreview(index),'ContentPreviewEnabled',setValue);
    end
end

function subsystems=loc_getSelectedSubsystemsWithPortLabel(cbinfo,portLabel)
    subsystems=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,portLabel);
end

function schema=PortLabelsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:PortLabelsMenu';
    schema.label=DAStudio.message('Simulink:studio:PortLabelsMenu');

    schema.obsoleteTags={'Simulink:ShowPortLabelsMenu'};
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:ConfigurePortLabelsActionText';
        schema.tooltip='simulink_ui:studio:resources:ConfigurePortLabelsActionDescription';
        schema.icon='portLabels';
    end

    subsystems=loc_getSelectedSubsystemsWithPortLabel(cbinfo,'any');
    if isempty(subsystems)
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    end


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:ShowPortLabelsNone'),...
    im.getAction('Simulink:ShowPortLabelsPortIcon'),...
    im.getAction('Simulink:ShowPortLabelsPortBlockName'),...
    im.getAction('Simulink:ShowPortLabelsSignalName')
    };
end


function schema=ShowPortLabelsNone(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowPortLabelsNone';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ShowPortLabelsNone');

    matchingSS=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,'none');
    schema.checked=SLStudio.Utils.logicalToString(isempty(matchingSS),'Unchecked','Checked');

    schema.userdata='none';
    schema.callback=@SetShowPortLabelsParamCB;
end

function schema=ShowPortLabelsPortIcon(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowPortLabelsPortIcon';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ShowPortLabelsPortIcon');

    matchingSS=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,'FromPortIcon');
    schema.checked=SLStudio.Utils.logicalToString(isempty(matchingSS),'Unchecked','Checked');

    schema.userdata='FromPortIcon';
    schema.callback=@SetShowPortLabelsParamCB;
end

function schema=ShowPortLabelsPortBlockName(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowPortLabelsPortBlockName';

    matchingSS=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,'FromPortBlockName');
    schema.checked=SLStudio.Utils.logicalToString(isempty(matchingSS),'Unchecked','Checked');

    schema.userdata='FromPortBlockName';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:portLabelFromBlockNameActionLabel';
    else
        schema.label=DAStudio.message('Simulink:studio:ShowPortLabelsPortBlockName');
    end
    schema.callback=@SetShowPortLabelsParamCB;
end

function schema=ShowPortLabelsSignalName(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowPortLabelsSignalName';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ShowPortLabelsSignalName');

    matchingSS=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,'SignalName');
    schema.checked=SLStudio.Utils.logicalToString(isempty(matchingSS),'Unchecked','Checked');

    schema.userdata='SignalName';
    schema.callback=@SetShowPortLabelsParamCB;
end

function SetShowPortLabelsParamCB(cbinfo,~)
    selectedSS=SLStudio.Utils.getSelectedSubsystemsWithPortLabel(cbinfo,'any');

    if~isempty(selectedSS)
        set(selectedSS,'ShowPortLabels',cbinfo.userdata);
    end
end

function state=loc_getMaskMenuState(cbinfo)
    state='Disabled';
    if(strcmpi(SLStudio.Utils.getAddEditMaskState(cbinfo),'Enabled')||...
        strcmpi(loc_getAddEditModelMaskState(cbinfo),'Enabled')||...
        strcmpi(loc_getAddEditRefSubsystemMaskState(cbinfo),'Enabled')||...
        strcmpi(loc_getLookUnderMaskState(cbinfo),'Enabled'))
        state='Enabled';
    end
end

function schema=MaskMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:MaskMenu';
    schema.label=DAStudio.message('Simulink:studio:MaskMenu');

    schema.state=loc_getMaskMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:AddEditMask'),...
    im.getAction('Simulink:CreateMaskOnLink'),...
    im.getAction('Simulink:AddEditRefSubsystemMask'),...
    im.getAction('Simulink:AddEditIconImage'),...
    im.getAction('Simulink:MaskParameters'),...
    im.getAction('Simulink:LookUnderMask'),...
    'separator',...
    im.getAction('Simulink:AddEditModelMask'),...
    im.getAction('Simulink:ModelMaskParameters')};

    schema.autoDisableWhen='Never';
end

function ismasked=loc_isAlreadyMasked(cbinfo)
    ismasked=SLStudio.Utils.callBoolMethodOnDomian(cbinfo,'isAlreadyMasked');
end

function schema=AddEditViewMask(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:AddEditViewMask';
    schema.label='AddEditViewMask';
    schema.state='Enabled';
    schema.callback=@AddEditViewMaskCB;
    schema.autoDisableWhen='Never';
end

function AddEditViewMaskCB(cbinfo)
    if SLStudio.Utils.getAddEditMaskState(cbinfo)=="Enabled"
        AddEditMaskCB(cbinfo);
    end
end

function schema=AddEditMask(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:AddEditMask';
    schema.state=SLStudio.Utils.getAddEditMaskState(cbinfo);
    schema.accelerator='Ctrl+M';
    isMaskReadOnly=false;
    isAlreadyMasked=false;
    if SLStudio.Utils.isMaskReadOnly(cbinfo)
        isMaskReadOnly=true;
        schema.label=DAStudio.message('Simulink:studio:ViewMask');
    else
        if loc_isAlreadyMasked(cbinfo)
            isAlreadyMasked=true;
            schema.label=DAStudio.message('Simulink:studio:EditMask');
        else
            schema.label=DAStudio.message('Simulink:studio:CreateMask');
        end
    end
    if SLStudio.Utils.showInToolStrip(cbinfo)
        if isMaskReadOnly
            schema.label='simulink_ui:studio:resources:viewMaskActionLabel';
            schema.icon='viewMask';
            schema.tooltip='simulink_ui:studio:resources:viewMaskActionDescription';
        else
            if isAlreadyMasked
                schema.label='simulink_ui:studio:resources:editMaskActionLabel';
                schema.icon='editMask';
                schema.tooltip='simulink_ui:studio:resources:editMaskActionDescription';
            else
                schema.label='simulink_ui:studio:resources:createMaskActionLabel';
                schema.icon='createMask';
            end
        end
    end
    schema.obsoleteTags={'Simulink:CreateMask'};
    schema.callback=@AddEditMaskCB;

    schema.autoDisableWhen='Never';
end

function AddEditMaskCB(cbinfo)
    cbinfo.domain.createOrEditMask();
end

function schema=AddEditIconImage(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AddEditIconImage';
    alreadyImageAdded=false;

    if SLStudio.Utils.isImageAlreadyAddedToMask(cbinfo)&&...
        strcmp(SLStudio.Utils.getAddEditIconImageMaskState(cbinfo),'Enabled')
        alreadyImageAdded=true;
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        if alreadyImageAdded
            schema.label='simulink_ui:studio:resources:editImageActionLabel';
            schema.icon='editImageForBlock';
            schema.tooltip='simulink_ui:studio:resources:editImageActionDescription';
        else
            schema.label='simulink_ui:studio:resources:addImageActionLabel';
            schema.icon='addImageToBlock';
            schema.tooltip='simulink_ui:studio:resources:addImageActionDescription';
        end
    else
        if alreadyImageAdded
            schema.label=DAStudio.message('Simulink:studio:EditIconImage');
        else
            schema.label=DAStudio.message('Simulink:studio:AddIconImage');
        end
    end

    schema.state=SLStudio.Utils.getAddEditIconImageMaskState(cbinfo);
    schema.callback=@AddEditIconImageCB;
    schema.autoDisableWhen='Never';


    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if(~isempty(block)&&isWebBlock(block))
        schema.state='Disabled';
    end
end


function schema=AddEditMaskIconImage(cbinfo)%#ok<DEFNU>
    schema=AddEditIconImage(cbinfo);
    if SLStudio.Utils.isImageAlreadyAddedToMask(cbinfo)&&...
        strcmp(SLStudio.Utils.getAddEditIconImageMaskState(cbinfo),'Enabled')
        schema.label='simulink_ui:studio:resources:editImageActionText';
    else
        schema.label='simulink_ui:studio:resources:addImageActionText';
    end


    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if(~isempty(block)&&isWebBlock(block))
        schema.state='Disabled';
    end
end

function AddEditIconImageCB(cbinfo)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    maskIconImageObj=Simulink.Mask.IconImageCreatorDialog(block.handle);
    maskIconImageObj.showDialog();
end

function ismodelmasked=loc_isModelAlreadyMasked(cbinfo)
    ismodelmasked=SLM3I.SLDomain.isModelAlreadyMasked(cbinfo.editorModel.handle);
end

function[bIsRootGraph]=loc_isRootGraph(cbinfo)
    bIsRootGraph=isa(cbinfo.uiObject,'Simulink.BlockDiagram');
end



function state=loc_getAddEditModelMaskState(cbinfo)
    visible=SLM3I.SLDomain.isCreateEditModelMaskEnabled(cbinfo.editorModel.handle);
    if visible
        aSelectedItem=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
        if loc_isRootGraph(cbinfo)&&(cbinfo.isMenuBar||isempty(aSelectedItem))
            state='Enabled';
        else
            state='Disabled';
        end
    else
        state='Hidden';
    end
end

function AddEditModelMaskCB(cbinfo)
    SLM3I.SLDomain.createOrEditModelMask(cbinfo.editorModel.handle);
end

function schema=AddEditModelMask(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AddEditModelMask';
    schema.state=loc_getAddEditModelMaskState(cbinfo);
    alreadyMasked=loc_isModelAlreadyMasked(cbinfo);

    if SLStudio.Utils.showInToolStrip(cbinfo)
        if alreadyMasked
            schema.label='simulink_ui:studio:resources:editModelMaskActionLabel';
            schema.tooltip='simulink_ui:studio:resources:editModelMaskActionLabel';
            schema.icon='editModelMask';
        else
            schema.label='simulink_ui:studio:resources:createModelMaskActionLabel';
            schema.tooltip='simulink_ui:studio:resources:createModelMaskActionLabel';
            schema.icon='createModelMask';
        end
    else
        if alreadyMasked
            schema.label=DAStudio.message('Simulink:studio:EditModelMask');
        else
            schema.label=DAStudio.message('Simulink:studio:CreateModelMask');
        end
    end

    schema.callback=@AddEditModelMaskCB;
    schema.autoDisableWhen='Never';
end

function isSSRef=isSSRefBlockPointingToAValidBD(block)
    isSSRef=false;
    if~isempty(block)&&strcmp(get_param(block.handle,'BlockType'),'SubSystem')...
        &&~isempty(slInternal('getActiveSRInstanceNames',block.handle))
        isSSRef=true;
    end
end

function exists=modelFileExists(model)
    exists=false;
    if(~isempty(model)&&exist(model,'file')==4)
        filepath=which(model);
        [~,fileName,~]=fileparts(filepath);
        exists=strcmp(model,fileName);
    end
end

function handle=getReferencedSubsystemHandle(block)
    handle=[];
    if isSSRefBlockPointingToAValidBD(block)
        child_model=get_param(block.handle,'ReferencedSubsystem');
        if modelFileExists(child_model)
            if bdIsLoaded(child_model)
                handle=get_param(child_model,'handle');
            end
        end
    end
end

function state=loc_getAddEditRefSubsystemMaskState(cbinfo)
    state='Hidden';

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if~isSSRefBlockPointingToAValidBD(block)
        return;
    end

    state='Disabled';
    refSubsystemHandle=getReferencedSubsystemHandle(block);
    if~isempty(refSubsystemHandle)
        if SLM3I.SLDomain.isCreateEditModelMaskEnabled(refSubsystemHandle)&&...
            ~slInternal('isSRGraphLockedForEditing',refSubsystemHandle)
            state='Enabled';
        end
    end
end

function AddEditRefSubsystemModelMaskCB(cbinfo)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    handle=getReferencedSubsystemHandle(block);
    if~isempty(handle)
        open_system(handle);
        SLM3I.SLDomain.createOrEditModelMask(handle);
    end
end

function schema=AddEditRefSubsystemMask(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:AddEditRefSubsystemMask';
    schema.state=loc_getAddEditRefSubsystemMaskState(cbinfo);

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    handle=getReferencedSubsystemHandle(block);
    alreadyMasked=false;
    refSubsystemName='';
    if~isempty(handle)
        alreadyMasked=SLM3I.SLDomain.isModelAlreadyMasked(handle);
        refSubsystemName=get_param(handle,'Name');
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        if alreadyMasked
            schema.label=DAStudio.message('simulink_ui:studio:resources:editRefSubsystemMaskLabel');
            schema.icon='editModelMaskOnRefSubsystem';
            if strcmp(schema.state,'Enabled')
                schema.tooltip=DAStudio.message('simulink_ui:studio:resources:editRefSubsystemMaskDescription',refSubsystemName);
            end
        else
            schema.label=DAStudio.message('simulink_ui:studio:resources:createRefSubsystemMaskLabel');
            schema.icon='createModelMaskOnRefSubsystem';
            if strcmp(schema.state,'Enabled')
                schema.tooltip=DAStudio.message('simulink_ui:studio:resources:createRefSubsystemMaskDescription',refSubsystemName);
            end
        end
    else
        if alreadyMasked
            schema.label=DAStudio.message('Simulink:studio:EditMaskOnRefSubsystem',refSubsystemName);
        else
            schema.label=DAStudio.message('Simulink:studio:CreateMaskOnRefSubsystem',refSubsystemName);
        end
    end

    schema.callback=@AddEditRefSubsystemModelMaskCB;
    schema.autoDisableWhen='Never';
end

function state=loc_getViewBaseMaskState(cbinfo)
    state='Hidden';
    item=SLStudio.Utils.getSingleSelectedBlock(cbinfo);



    if~isempty(item)
        h=item.handle;
        if strcmp(get_param(h,'StaticLinkStatus'),'resolved')&&~isempty(Simulink.Mask.get(h))
            state='Enabled';
        end
    end
end

function schema=ViewBaseMask(cbinfo)
    schema=sl_action_schema;

    schema.tag='Simulink:ViewBaseMask';
    schema.state=loc_getViewBaseMaskState(cbinfo);
    schema.label='simulink_ui:studio:resources:viewBaseMaskActionLabel';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='baseMask';
    end
    schema.callback=@ViewBaseMaskCB;
    schema.autoDisableWhen='Never';
end

function ViewBaseMaskCB(cbinfo)
    aSelectedItem=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(aSelectedItem)
        return;
    end

    aBlockHdl=aSelectedItem.handle;

    if strcmp(aSelectedItem.type,'SimscapeMultibodyBlock')
        open_system(aBlockHdl);
        return;
    end

    aLinkStatus=get_param(aBlockHdl,'StaticLinkStatus');
    if~strcmp(aLinkStatus,'resolved')
        return;
    end

    aReferenceBlockPath=get_param(aBlockHdl,'ReferenceBlock');
    aLibName=strtok(aReferenceBlockPath,'/');
    load_system(aLibName);

    aParentName=get_param(aReferenceBlockPath,'Parent');
    aParentHdl=get_param(aParentName,'Handle');
    aAlreadySelected=find_system(aParentName,'SearchDepth',1,'selected','on');
    if~iscell(aAlreadySelected)
        aAlreadySelected={aAlreadySelected};
    end

    for i=1:length(aAlreadySelected)
        set_param(aAlreadySelected{i},'selected','off');
    end

    set_param(aReferenceBlockPath,'selected','on');
    excludeInvisibleSubsystems=false;

    slInternal('createOrEditMask',aParentHdl,excludeInvisibleSubsystems);
end

function state=loc_getCreateMaskOnLinkState(cbinfo)
    state='Hidden';
    item=SLStudio.Utils.getSingleSelectedBlock(cbinfo);



    if~isempty(item)
        h=item.handle;
        if strcmp(get_param(h,'StaticLinkStatus'),'resolved')
            [~,bCanCreateNewMask]=Simulink.Mask.get(h);
            if(bCanCreateNewMask)

            end
        end
    end
end

function schema=CreateMaskOnLink(cbinfo)
    schema=sl_action_schema;

    schema.tag='Simulink:CreateMaskOnLink';
    schema.state=loc_getCreateMaskOnLinkState(cbinfo);

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:createMaskOnLinkActionLabel';
        schema.icon='createMaskOnLink';
    else
        schema.label=DAStudio.message('Simulink:studio:CreateMaskOnLink');
    end
    schema.callback=@CreateMaskOnLinkCB;
    schema.autoDisableWhen='Never';
end

function CreateMaskOnLinkCB(cbinfo)
    aSelectedItem=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(aSelectedItem)
        return;
    end

    aBlockHdl=aSelectedItem.handle;

    aLinkStatus=get_param(aBlockHdl,'StaticLinkStatus');
    if~strcmp(aLinkStatus,'resolved')
        return;
    end

    [~,bCanCreateNewMask]=Simulink.Mask.get(aBlockHdl);
    if~bCanCreateNewMask
        return;
    end

    cbinfo.domain.createOrEditMask();
    maskeditor('CreateMaskOnLink',aBlockHdl);
end

function state=loc_getMaskParametersState(cbinfo)
    enabled=SLStudio.Utils.callBoolMethodOnDomian(cbinfo,'isMaskParametersItemEnabled');
    if enabled
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=MaskParameters(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:MaskParameters';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='blockDialogParameters';
    else
        schema.label=DAStudio.message('Simulink:studio:MaskParameters');
    end

    schema.state=loc_getMaskParametersState(cbinfo);
    schema.callback=@MaskParametersCB;

    schema.autoDisableWhen='Never';
end

function schema=BaseMaskParameters(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:MaskParameters';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:baseMaskParametersActionLabel';
        schema.icon='baseMaskParameters';
    else
        schema.label=DAStudio.message('Simulink:studio:MaskParameters');
    end

    schema.state=loc_getMaskParametersState(cbinfo);
    schema.callback=@MaskParametersCB;

    schema.autoDisableWhen='Never';
end

function MaskParametersCB(cbinfo)
    cbinfo.domain.openMaskDialogParams();
end

function state=loc_getModelMaskParametersState(cbinfo)
    visible=SLM3I.SLDomain.isModelMaskParametersItemEnabled(cbinfo.model.handle);
    if visible
        if loc_isRootGraph(cbinfo)
            state='Enabled';
        else
            state='Disabled';
        end
    else
        state='Hidden';
    end
end

function ModelMaskParametersCB(cbinfo)
    SLM3I.SLDomain.openModelMaskDialogParams(cbinfo.model.handle);
end

function schema=ModelMaskParameters(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelMaskParameters';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:modelMaskParametersActionLabel';
        schema.tooltip='simulink_ui:studio:resources:modelMaskParametersActionLabel';
        schema.icon='parametersModelMask';
    else
        schema.label=DAStudio.message('Simulink:studio:ModelMaskParameters');
    end


    schema.state=loc_getModelMaskParametersState(cbinfo);
    schema.callback=@ModelMaskParametersCB;

    schema.autoDisableWhen='Never';
end

function state=loc_getLookUnderMaskState(cbinfo)
    enabled=SLStudio.Utils.callBoolMethodOnDomian(cbinfo,'isLookUnderMaskEnabled');
    if enabled
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=LookUnderMask(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:LookUnderMask';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:lookUnderMaskActionLabel';
        schema.icon='lookUnderMask';
    else
        schema.label=DAStudio.message('Simulink:studio:LookUnderMask');
    end
    schema.accelerator='Ctrl+U';
    schema.state=loc_getLookUnderMaskState(cbinfo);
    schema.callback=@LookUnderMaskCB;

    schema.autoDisableWhen='Never';
end

function schema=LookUnderBaseMask(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:LookUnderBaseMask';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:lookUnderBaseMaskActionLabel';
        schema.icon='baseMaskLookUnder';
    else
        schema.label=DAStudio.message('Simulink:studio:LookUnderMask');
    end
    schema.accelerator='Ctrl+U';
    schema.state=loc_getLookUnderMaskState(cbinfo);
    schema.callback=@LookUnderMaskCB;

    schema.autoDisableWhen='Never';
end

function LookUnderMaskCB(cbinfo)
    app=cbinfo.studio.App;
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    assert(SLStudio.Utils.objectIsValidBlock(target));
    openReq=SLM3I.BlockLookUnderMaskOpenRequest(target.handle);
    hid=cbinfo.targetHID;
    app.processOpenRequest(openReq,hid);
end

function state=loc_getBlockParametersState(cbinfo)
    state='Disabled';
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(obj)&&~cbinfo.studio.App.hasSpotlightView()
        state='Enabled';
    end
end

function schema=BlockParametersMenuDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:BlockParameters';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:BlockParameters','');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=BlockParameters(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:BlockParameters';
    item=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    blkType='';
    if(~isempty(item))
        type=get_param(item.handle,'BlockType');
        if strcmpi(type,'SubSystem')
            type='Subsystem';
        end







        bIsCoreWebBlock=get_param(item.handle,'IsCoreWebBlock');
        if strcmpi(bIsCoreWebBlock,'on')
            if~strcmpi(type,'CallbackButton')
                blkType=[''];
            else
                blkType=['(',type,')'];
            end
        else
            blkType=['(',type,')'];
        end
    end


    schema.label=DAStudio.message('Simulink:studio:BlockParameters',blkType);
    schema.state=loc_getBlockParametersState(cbinfo);
    schema.callback=@BlockParametersCB;

    schema.autoDisableWhen='Never';
end

function BlockParametersCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        open_system(block.handle,'parameter');
    end
end




function schema=ConfigurableSubSystem(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ConfigurableSubSystem';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ConfigurableSubSystem');
    end
    schema.state=loc_getConfigSubSystemMenuState(cbinfo);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
    schema.autoDisableWhen='Busy';


    if(strcmpi(schema.state,'Enabled'))
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        blockH='';
        if SLStudio.Utils.objectIsValidBlock(block)
            blockH=block.handle;
        end
        if(ishandle(blockH))
            m=get_param(blockH,'MemberBlocks');
            m1=regexprep(m,'\n',' ');
            memberStr=textscan(m1,'%s','delimiter',',');
            members=cellstr(memberStr{1});
            membersN=length(members);
            if(membersN~=0)
                childrenFcns=cell(membersN,1);
                for index=1:membersN
                    childrenFcns{index}={@AddConfigSubsystemMembers,{index,members{index},blockH}};
                end
                schema.childrenFcns=childrenFcns;
            end
        end
    end
end

function state=loc_getConfigSubSystemMenuState(cbinfo)
    state='Hidden';
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blockH=block.handle;

        if ishandle(blockH)



            if block.isConfigurableSubsystem
                members=get_param(blockH,'MemberBlocks');
                state='Disabled';
                if(~isempty(members))
                    state='Enabled';
                end
            end
        end
    end
end



function state=loc_SubsysToVSSmenuState(cbinfo)
    state='Hidden';

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);



    if SLStudio.Utils.objectIsValidBlock(block)&&...
        ~block.isConfigurableSubsystem

        blockH=block.handle;

        if Simulink.harness.internal.isHarnessCUT(blockH)
            state='Disabled';
            return;
        end


        if(strcmp(get_param(blockH,'BlockType'),'SubSystem')&&~isempty(get_param(blockH,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'))))
            state='Disabled';
            return;
        end





        if ishandle(blockH)&&(strcmp(get_param(blockH,'BlockType'),'SubSystem')||strcmp(get_param(blockH,'BlockType'),'ModelReference'))
            if SLStudio.Utils.isLockedSystem(cbinfo)
                state='Disabled';
            else
                state='Enabled';
            end
        end
    end
end


function schema=AddConfigSubsystemMembers(cbinfo)
    mIndex=cbinfo.userdata{1};
    mName=cbinfo.userdata{2};
    blockH=cbinfo.userdata{3};
    schema=sl_toggle_schema;
    schema.label=mName;
    schema.tag=['Simulink:ConfigSubsystemMembers_',num2str(mIndex)];
    schema.userdata={blockH,mName};
    schema.callback=@AddConfigSubsystemMembersCB;
    choice=get_param(blockH,'BlockChoice');
    if(strcmpi(choice,mName))
        schema.checked='Checked';
    end
    schema.autoDisableWhen='Busy';
end

function AddConfigSubsystemMembersCB(cbinfo)
    blockH=cbinfo.userdata{1};
    parentH=SLM3I.SLDomain.getTopmostLinkedOrConfiguredParent(blockH);

    try


        if ishandle(parentH)
            allowChanges=SLM3I.SLDomain.showLinkDataWarningDialog(parentH,blockH);
            if allowChanges
                set_param(blockH,'BlockChoice',cbinfo.userdata{2});
            end
        else
            set_param(blockH,'BlockChoice',cbinfo.userdata{2});
        end
    catch ME
        sldiagviewer.reportError(ME.message,'MessageId',ME.identifier);
    end
end

function readOnlyParent=isChildOfReadyOnlySubsystem(blockH)
    readOnlyParent=false;
    if(strcmp(get_param(blockH,'Type'),'block'))
        if(strcmp(get_param(blockH,'BlockType'),'SubSystem'))
            permission=get_param(blockH,'Permissions');
            if(~strcmp(permission,'ReadWrite'))
                readOnlyParent=true;
                return;
            end
        end


        parent=get_param(blockH,'Parent');
        readOnlyParent=isChildOfReadyOnlySubsystem(parent);
    elseif(strcmp(get_param(blockH,'Type'),'block_diagram'))
        lock=get_param(blockH,'Lock');
        if(strcmp(lock,'on'))
            readOnlyParent=true;
            return;
        end
    end
end




function blockH=loc_getOneMenuTargetOrGraph(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    blockH=[];
    if SLStudio.Utils.objectIsValidBlock(block)
        blockH=block.handle;
    else


        object=get_param(cbinfo.uiObject.handle,'Object');
        fullName=object.getFullName;
        modelName=bdroot(fullName);
        if strcmp(fullName,modelName)
            return;
        else

            blockH=get_param(fullName,'Handle');
        end
    end
end

function flag=isVariantSourceSinkBlock(blockH)
    flag=false;
    if isempty(blockH)
        return;
    end


    blockType=get_param(blockH,'BlockType');
    flag=strcmp(blockType,'VariantSource')||strcmp(blockType,'VariantSink');
end

function variantConnectorBlk=isVariantConnectorBlock(blockH)
    variantConnectorBlk=false;
    if isempty(blockH)
        return;
    end

    blockType=get_param(blockH,'BlockType');

    if(strcmp(blockType,'VariantPMConnector'))
        variantConnectorBlk=true;
    end
end

function validBlock=isValidVariantBlockForOverrideUsingVariant(blockH)
    validBlock=false;
    if isempty(blockH)
        return;
    end

    blockType=get_param(blockH,'BlockType');


    if(strcmp(blockType,'ModelReference')||...
        strcmp(blockType,'SubSystem'))

        if strcmp(get_param(blockH,'Variant'),'on')
            validBlock=true;
        end
    end


    if(isVariantSourceSinkBlock(blockH)||isVariantConnectorBlock(blockH))
        validBlock=true;
    end
end

function validBlock=isValidVariantBlock(blockH)
    validBlock=false;
    if isempty(blockH)
        return;
    end

    blockType=get_param(blockH,'BlockType');


    if(strcmp(blockType,'ModelReference')||...
        strcmp(blockType,'SubSystem'))

        if strcmp(get_param(blockH,'Variant'),'on')
            validBlock=true;
        end
    end



    if(isVariantSourceSinkBlock(blockH)||isVariantConnectorBlock(blockH))
        validBlock=true;
    end




    if slInternal('isSimulinkFunction',blockH)

        fcnBlk=find_system(blockH,'SearchDepth',1,'BlockType','TriggerPort');
        validBlock=~isempty(fcnBlk)&&...
        strcmp(get_param(fcnBlk,'Variant'),'on');
    end


    if slInternal('isInitTermOrResetSubsystem',blockH)
        evBlk=find_system(blockH,'SearchDepth',1,'BlockType','EventListener');
        validBlock=~isempty(evBlk)&&...
        strcmp(get_param(evBlk,'Variant'),'on');
    end
end


function state=loc_getVariantMenuState(cbinfo,checkForLocked)
    state='Hidden';
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    if ishandle(blockH)
        validBlock=isValidVariantBlock(blockH);
        if(validBlock)
            state='Enabled';
            readOnlyParent=isChildOfReadyOnlySubsystem(get_param(blockH,'Parent'));
            if(readOnlyParent&&checkForLocked)
                state='Disabled';
            end
        end
    end
end


function state=loc_getVariantChoicesMenuState(cbinfo,checkForLocked)
    state='Hidden';
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    if ishandle(blockH)
        validBlock=isValidVariantBlockForOverrideUsingVariant(blockH);
        if(validBlock)
            state='Enabled';
            readOnlyParent=isChildOfReadyOnlySubsystem(get_param(blockH,'Parent'));
            if(readOnlyParent&&checkForLocked)
                state='Disabled';
            end
        end
    end
end

function schema=VariantMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:VariantMenu';
    schema.label=DAStudio.message('Simulink:studio:Variant');
    schema.state=loc_getVariantMenuState(cbinfo,false);



    blockH=loc_getOneMenuTargetOrGraph(cbinfo);






    variantControlModeIsLabel=false;
    if~isempty(blockH)
        blockType=get_param(blockH,'BlockType');
        isVSSOrIVBlk=(strcmp(blockType,'SubSystem')&&strcmp(get_param(blockH,'Variant'),'on'))||...
        isVariantSourceSinkBlock(blockH);
        variantControlModeIsLabel=isVSSOrIVBlk&&strcmp(get_param(blockH,'VariantControlMode'),'label');
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    if variantControlModeIsLabel
        schema.childrenFcns={
        im.getSubmenu('Simulink:VariantOpen'),...
        im.getSubmenu('Simulink:VariantChoice'),...
        im.getAction('Simulink:OpenVariantInVariantManager')
        };
    else


        schema.childrenFcns={
        im.getSubmenu('Simulink:VariantOpen'),...
        im.getAction('Simulink:OpenVariantInVariantManager')
        };
    end
    schema.autoDisableWhen='Busy';
end

function ToolStripVariantActiveChoice(cbinfo,action)%#ok<DEFNU>
    action.description=DAStudio.message('Simulink:studio:ActiveVariantChoice');
    if(strcmp(get_param(cbinfo.model.Name,'BlockDiagramType'),'library'))
        action.enabled=false;
    elseif strcmpi(loc_getVariantChoicesMenuState(cbinfo,false),'enabled')
        action.enabled=true;
    else
        action.enabled=false;
    end


    if(action.enabled)
        blockH=loc_getOneMenuTargetOrGraph(cbinfo);
        if(ishandle(blockH))
            entries=[];
            blockType=get_param(blockH,'BlockType');

            if strcmp(blockType,'ModelReference')
                allVars=get_param(blockH,'Variants');
                membersN=length(allVars);
                if(membersN>0)
                    for index=1:membersN
                        e=dig.model.ActionEntry;
                        e.value=allVars(index).Name;
                        e.text=allVars(index).Name;
                        entries=[entries,e];%#ok<AGROW>
                    end
                end
            elseif strcmp(blockType,'SubSystem')
                allVars=get_param(blockH,'Variants');


                nVars=length(allVars);
                for i=nVars:-1:1




                    if(strncmp(allVars(i).Name,'%',1)||...
                        strcmp(allVars(i).Name,''))

                        allVars(i)=[];
                    end
                end
                membersN=length(allVars);
                if(membersN>0)
                    for index=1:membersN
                        e=dig.model.ActionEntry;
                        e.value=allVars(index).Name;
                        e.text=allVars(index).Name;
                        entries=[entries,e];%#ok<AGROW>
                    end
                end
            elseif isVariantSourceSinkBlock(blockH)
                allVars=get_param(blockH,'VariantControls');



                nVars=length(allVars);
                for i=nVars:-1:1


                    if(strncmp(allVars(i),'%',1))
                        allVars(i)=[];
                    end
                end

                membersN=length(allVars);
                if(membersN>0)

                    for index=1:membersN
                        e=dig.model.ActionEntry;
                        e.value=allVars{index};
                        e.text=allVars{index};
                        entries=[entries,e];%#ok<AGROW>
                    end
                end
            end

            if~isempty(entries)
                action.validateAndSetActionEntries(entries);
                action.setCallbackFromArray(@AddVariantChoiceMemberCB_toolstrip,dig.model.FunctionType.Action);
                blockType=get_param(blockH,'BlockType');
                paramName='LabelModeActiveChoice';

                choice=get_param(blockH,paramName);
                if(any(arrayfun(@(x)strcmpi(choice,x.value),entries)))
                    action.selectedItem=choice;
                else
                    action.selectedItem='';
                end
            else
                action.validateAndSetEntries({});
                action.enabled=false;
            end
        end
    end
end

function openVariantButtonActionRF(cbinfo,action)%#ok<DEFNU>
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    if(strcmp(get_param(cbinfo.model.Name,'BlockDiagramType'),'library'))
        action.enabled=false;
    elseif(ishandle(blockH))
        blockType=get_param(blockH,'BlockType');
        if strcmp(blockType,'ModelReference')||...
            strcmp(blockType,'SubSystem')
            allVars=get_param(blockH,'Variants');
            membersN=length(allVars);
            if(membersN>0)
                action.enabled=true;
            else
                action.enabled=false;
            end
        end
    end
end

function schema=VariantOpenMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:VariantOpen';
    schema.label=DAStudio.message('Simulink:studio:VariantOpen');
    if(isVariantSourceSinkBlock(loc_getOneMenuTargetOrGraph(cbinfo))||isVariantConnectorBlock(loc_getOneMenuTargetOrGraph(cbinfo)))
        schema.state='Hidden';
    else
        schema.state=loc_getVariantChoicesMenuState(cbinfo,false);
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
    schema.autoDisableWhen='Busy';


    if(strcmpi(schema.state,'Enabled'))
        blockH=loc_getOneMenuTargetOrGraph(cbinfo);
        if(ishandle(blockH))
            blockType=get_param(blockH,'BlockType');
            childrenFcns={};
            if strcmp(blockType,'ModelReference')||...
                strcmp(blockType,'SubSystem')
                allVars=get_param(blockH,'Variants');
                membersN=length(allVars);
                if(membersN>0)
                    childrenFcns=cell(membersN+1,1);
                    childrenFcns{1}={@AddVariantMember,{1,'(active variant)',blockH}};
                    for index=1:membersN
                        if(strcmp(blockType,'ModelReference'))
                            childrenFcns{index+1}={@AddVariantMember,...
                            {index+1,[allVars(index).Name,' (',allVars(index).ModelName,')'],blockH}};
                        else


                            BlkName=get_param(allVars(index).BlockName,'Name');
                            childrenFcns{index+1}={@AddVariantMember,...
                            {index+1,[allVars(index).Name,' (',BlkName,')'],blockH}};
                        end
                    end
                end
            end

            if~isempty(childrenFcns)
                schema.childrenFcns=childrenFcns;
            end
        end
    end
end

function schema=AddVariantMember(cbinfo)
    mIndex=cbinfo.userdata{1};
    mName=cbinfo.userdata{2};
    blockH=cbinfo.userdata{3};
    schema=sl_action_schema;
    schema.label=mName;
    schema.tag=['Simulink:VariantMember_',num2str(mIndex)];
    schema.userdata={blockH,mName};
    schema.callback=@AddVariantMemberCB;
    schema.autoDisableWhen='Busy';
end

function gw=openVariantSubsystemToolstrip(cbinfo)
    gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);

    blockH=loc_getOneMenuTargetOrGraph(cbinfo);

    if ishandle(blockH)
        blockType=get_param(blockH,'BlockType');
        if strcmp(blockType,'ModelReference')||...
            strcmp(blockType,'SubSystem')
            allVars=get_param(blockH,'Variants');
            membersN=length(allVars);
            if(membersN>0)

                createVariantItem(gw,1,'(active variant)');

                for index=1:membersN
                    BlkName=get_param(allVars(index).BlockName,'Name');
                    createVariantItem(gw,index+1,[allVars(index).Name,' (',BlkName,')']);
                end
            end
        end
    end
end

function[item,action]=createVariantItem(gw,index,text)
    itemName=['Item',num2str(index)];
    item=gw.Widget.addChild('ListItem',itemName);
    actionId=['itemAction',num2str(index)];
    item.ActionId=['openVariantSubsystemPopup:',actionId];

    action=gw.createAction(actionId);
    action.text=text;
    action.enabled=true;
    action.setCallbackFromArray({'SLStudio.DiagramMenu','AddVariantMemberCB_toolstrip',text},dig.model.FunctionType.Action);
    action.optOutBusy=true;
    action.optOutLocked=true;
end

function AddVariantMemberCB_common(blockH,variantValue)
    blockType=get_param(blockH,'BlockType');
    if strcmp(blockType,'ModelReference')||...
        strcmp(blockType,'SubSystem')

        allVars=get_param(blockH,'Variants');
        if contains(variantValue,'active variant')
            variantValue=get_param(blockH,'ActiveVariant');
            if(isempty(variantValue))



                open_system(blockH);
                return;
            end
            idx=find(strcmp({allVars.Name},variantValue));
            if~isempty(idx)
                if(strcmp(blockType,'ModelReference'))
                    sysName=allVars(idx).ModelName;
                else
                    sysName=allVars(idx).BlockName;
                end
                open_system(sysName);
            end
        else
            for i=1:numel(allVars)
                if(strcmp(blockType,'ModelReference'))
                    sysName=allVars(i).ModelName;
                    variantValue_act=[allVars(i).Name,' (',sysName,')'];
                else
                    sysName=allVars(i).BlockName;
                    variantValue_act=[allVars(i).Name,' (',get_param(sysName,'Name'),')'];
                end

                if(strcmp(variantValue_act,variantValue))
                    open_system(sysName);
                    break;
                end
            end
        end
    end
end

function AddVariantMemberCB_toolstrip(userdata,cbinfo)
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    variantValue=userdata;
    AddVariantMemberCB_common(blockH,variantValue);
end

function AddVariantMemberCB(cbinfo)
    blockH=cbinfo.userdata{1};
    variantValue=cbinfo.userdata{2};
    AddVariantMemberCB_common(blockH,variantValue);
end


function schema=VariantChoicesMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:VariantChoices';
    schema.label=DAStudio.message('Simulink:studio:ActiveVariantChoice');
    schema.state=loc_getVariantChoicesMenuState(cbinfo,true);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
    schema.autoDisableWhen='Busy';

    if(strcmpi(schema.state,'Enabled'))
        blockH=loc_getOneMenuTargetOrGraph(cbinfo);
        if(ishandle(blockH))
            blockType=get_param(blockH,'BlockType');
            childrenFcns={};
            if strcmp(blockType,'ModelReference')
                allVars=get_param(blockH,'Variants');
                membersN=length(allVars);
                if(membersN>0)
                    childrenFcns=cell(membersN,1);
                    childrenFcns{1}={@AddVariantChoiceMember,{1,blockH}};
                    for index=1:membersN
                        childrenFcns{index}={@AddVariantChoiceMember,...
                        {index,allVars(index),blockH}};
                    end
                end
            elseif strcmp(blockType,'SubSystem')
                allVars=get_param(blockH,'Variants');


                nVars=length(allVars);
                for i=nVars:-1:1




                    if(strncmp(allVars(i).Name,'%',1)||...
                        strcmp(allVars(i).Name,''))

                        allVars(i)=[];
                    end
                end
                membersN=length(allVars);
                if(membersN>0)
                    childrenFcns=cell(membersN,1);
                    childrenFcns{1}={@AddVariantChoiceMember,{0,blockH}};
                    for index=1:membersN
                        childrenFcns{index}={@AddVariantChoiceMember,...
                        {index,allVars(index),blockH}};
                    end
                end
            elseif(isVariantSourceSinkBlock(blockH)||isVariantConnectorBlock(blockH))
                allVars=get_param(blockH,'VariantControls');



                nVars=length(allVars);
                for i=nVars:-1:1


                    if(strncmp(allVars(i),'%',1))
                        allVars(i)=[];
                    end
                end

                membersN=length(allVars);
                if(membersN>0)
                    childrenFcns=cell(membersN,1);
                    childrenFcns{1}={@AddVariantPortMembers,{0,blockH}};
                    for index=1:membersN
                        childrenFcns{index}={@AddVariantPortMembers,...
                        {index,allVars(index),blockH}};
                    end
                end

            end
            if~isempty(childrenFcns)
                schema.childrenFcns=childrenFcns;
            end
        end
    end
end

function schema=AddVariantChoiceMember(cbinfo)
    mIndex=cbinfo.userdata{1};
    schema=sl_toggle_schema;
    blockH=cbinfo.userdata{3};
    if~isstruct(cbinfo.userdata{2})
        assert(~isempty(strfind(cbinfo.userdata{2},'disabled')));
        mName=cbinfo.userdata{2};
        schema.label=mName;
    else
        mName=cbinfo.userdata{2}.Name;
        if strcmp(get_param(blockH,'BlockType'),'ModelReference')
            schema.label=[cbinfo.userdata{2}.Name,' (',cbinfo.userdata{2}.ModelName,')'];
        else
            schema.label=[cbinfo.userdata{2}.Name,' (',get_param(cbinfo.userdata{2}.BlockName,'Name'),')'];
        end
    end
    schema.tag=['Simulink:VariantChoiceMember_',num2str(mIndex)];
    schema.userdata={blockH,mName};
    schema.callback=@AddVariantChoiceMemberCB;
    schema.autoDisableWhen='Busy';
    choice=get_param(blockH,'LabelModeActiveChoice');


    if isempty(choice)&&~isempty(strfind(mName,'disabled'))
        schema.checked='Checked';
    else
        mName=strtrim(mName);
        if~isempty(mName)&&strcmp(choice,mName)
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end
    end
end

function schema=AddVariantPortMembers(cbinfo)
    mIndex=cbinfo.userdata{1};
    srcPort=cbinfo.userdata{2};
    schema=sl_toggle_schema;
    blockH=cbinfo.userdata{3};
    if iscell(srcPort)
        schema.label=srcPort{1};
    else
        schema.label=srcPort;
    end
    schema.tag=['Simulink:VariantChoiceMember_',num2str(mIndex)];
    schema.userdata={blockH,srcPort};
    schema.callback=@AddVariantChoiceMemberCB;
    schema.autoDisableWhen='Busy';
    choice=get_param(blockH,'LabelModeActiveChoice');


    if isempty(choice)&&~isempty(strfind(schema.label,'disabled'))
        schema.checked='Checked';
    else
        srcPort=strtrim(srcPort);
        if~isempty(srcPort)&&strcmp(choice,srcPort)
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end
    end
end

function AddVariantChoiceMemberCB_common(blockH,newValue)
    parentH=SLM3I.SLDomain.getTopmostLinkedOrConfiguredParent(blockH);
    if iscell(newValue)
        newValue=newValue{1};
    end


    warnstate=warning;
    warning('off','Simulink:Commands:SetParamLinkChangeWarn');


    newValue=strtrim(newValue);



    blockType=get_param(blockH,'BlockType');
    paramName='LabelModeActiveChoice';

    if ishandle(parentH)
        allowChanges=SLM3I.SLDomain.showLinkDataWarningDialog(parentH,blockH);
        if allowChanges
            if strfind(newValue,'disabled')
                set_param(blockH,paramName,'');
            else
                set_param(blockH,paramName,newValue);
            end
        end
    else
        if strfind(newValue,'disabled')
            set_param(blockH,paramName,'');
        else
            set_param(blockH,paramName,newValue);
        end
    end



    warning(warnstate);
end

function AddVariantChoiceMemberCB_toolstrip(cbinfo)
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    newValue=cbinfo.EventData;
    AddVariantChoiceMemberCB_common(blockH,newValue);
end

function AddVariantChoiceMemberCB(cbinfo)
    blockH=cbinfo.userdata{1};
    newValue=cbinfo.userdata{2};

    AddVariantChoiceMemberCB_common(blockH,newValue);
end

function schema=OpenVariantInVariantManagerMenu(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:OpenVariantInVariantManager';
    schema.label=DAStudio.message('Simulink:studio:OpenInVariantManager');
    schema.autoDisableWhen='Busy';
    schema.state=loc_getVariantMenuState(cbinfo,true);
    schema.callback=@OpenVariantInVariantManagerCB;
end

function OpenVariantInVariantManagerCB(cbinfo)
    blockH=loc_getOneMenuTargetOrGraph(cbinfo);
    if is_simulink_handle(blockH)
        activeEditor=cbinfo.studio.App.getActiveEditor();
        blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,blockH);
        rootModelName=get_param(cbinfo.studio.App.topLevelDiagram.handle,'Name');
        expandSelectedRow=true;



        Simulink.variant.utils.launchVariantManager('CreateAndNavigate',rootModelName,blockPath,expandSelectedRow);
    end
end

function state=loc_getObjectPropertiesState(cbinfo)
    state='Disabled';
    if cbinfo.studio.App.hasSpotlightView()
        return;
    end

    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(obj)||...
        SLStudio.Utils.objectIsValidAnnotation(obj)
        state='Enabled';
    else
        l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
        if SLStudio.Utils.objectIsValidLine(l)&&...
            ~SLStudio.Utils.isConnectionLineSelected(cbinfo)
            state=loc_getSignalPropertiesState(cbinfo);
        end
    end
end

function schema=ObjectPropertiesDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ObjectProperties';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:ObjectProperties');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=ObjectProperties(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ObjectProperties';
    schema.label=DAStudio.message('Simulink:studio:ObjectProperties');
    schema.obsoleteTags={'Simulink:BlockProperties','Simulink:AnnotationProperties'};
    schema.state=loc_getObjectPropertiesState(cbinfo);
    schema.callback=@ObjectPropertiesCB;

    schema.autoDisableWhen='Never';
end

function ObjectPropertiesCB(cbinfo)
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(obj)
        open_system(obj.handle,'property');
    elseif SLStudio.Utils.objectIsValidAnnotation(obj)
        note=get_param(obj.handle,'Object');
        if~isempty(note.imagePath)
            tag='_DDG_IMAGE_PROPS_TAG_';
            found=SLStudio.Utils.showDialogIfExists(tag,note);
            if~found
                DAStudio.Dialog(note,tag,'DLG_STANDALONE');
            end
        else
            tag='_DDG_ANNOTATION_PROPS_TAG_';
            found=SLStudio.Utils.showDialogIfExists(tag,note);
            if~found
                DAStudio.Dialog(note,tag,'DLG_STANDALONE');
            end
        end
    else
        SignalPropertiesCB(cbinfo);
    end
end

function schema=RenameAll(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RenameAll';
    schema.label=DAStudio.message('Simulink:studio:RenameAll');

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if(SLStudio.Utils.objectIsValidBlock(block)&&...
        strcmpi(get_param(block.handle,'BlockType'),'DataStoreMemory')&&...
        bitand(slfeature('RenameDataStoreMemory'),2)>0)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    schema.callback=@RenameAllCB;
end

function RenameAllCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if(SLStudio.Utils.objectIsValidBlock(block))
        newName=get_param(block.handle,'DataStoreName');
        dlg=SLStudio.RenameDataStoreDialog(block.handle,newName);
        DAStudio.Dialog(dlg,'','DLG_STANDALONE');
    end
end

function schema=SignalsMenuDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:SignalsMenu';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:SignalsMenu');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=SignalsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:SignalsMenu';
    schema.label=DAStudio.message('Simulink:studio:SignalsMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');


    schema.childrenFcns={im.getAction('Simulink:SignalAndScopeManager'),...
    im.getSubmenu('Simulink:ViewersMenu'),...
    'separator',...
    im.getSubmenu('Simulink:BlockInportsMenu'),...
    im.getSubmenu('Simulink:BlockOutportsMenu'),...
    im.getAction('Simulink:PositionPorts'),...
    'separator',...
    {im.getAction('Simulink:SignalHierarchy'),'DiagramMenu'}
    };

    schema.autoDisableWhen='Never';
end

function state=loc_getSignalAndScopeManagerState(cbinfo)
    state='Enabled';
    if cbinfo.model.isLibrary||SLStudio.Utils.isConnectionLineSelected(cbinfo)
        state='Disabled';
    end
end

function schema=SignalAndScopeManager(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SignalAndScopeManager';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SignalAndScopeManager');
    schema.state=loc_getSignalAndScopeManagerState(cbinfo);
    schema.callback=@SignalAndScopeManagerCB;

    schema.autoDisableWhen='Never';
end

function SignalAndScopeManagerCB(cbinfo)
    selected=0;
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSigGenPort(obj)
        selected=SLStudio.Utils.getSigGenSourceBlock(obj);
    end





    sigandscopemgr('Create',cbinfo.editorModel.handle,selected);

    sigandscopemgr('GetLibraries');
    Simulink.scopes.SigScopeMgr.showSigScopeMgr(cbinfo,selected);

end

function state=loc_getViewersMenuState(cbinfo,childrenFcns)
    state='Disabled';

    for index=1:length(childrenFcns)
        generator=childrenFcns{index};
        schema=dasprivate('dig_get_schema',generator,cbinfo);
        if~ischar(generator)
            if~isempty(schema)&&strcmpi(schema.state,'Enabled')
                state='Enabled';
                break;
            end
        end
    end
end

function schema=ViewersMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ViewersMenu';
    schema.label=DAStudio.message('Simulink:studio:ViewersMenu');


    if cbinfo.model.isLibrary
        schema.state='Hidden';
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getSubmenu('Simulink:OpenViewerMenu'),...
    im.getSubmenu('Simulink:CreateAndConnectViewerMenu'),...
    im.getSubmenu('Simulink:ConnectToExistingViewerMenu'),...
    'separator',...
    im.getSubmenu('Simulink:DisconnectViewerMenu'),...
    im.getSubmenu('Simulink:DeleteViewerMenu')
    };


    schema.state=loc_getViewersMenuState(cbinfo,schema.childrenFcns);

    schema.autoDisableWhen='Busy';
end

function schema=OpenViewerMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_OpenViewerMenu(cbinfo);

    schema.autoDisableWhen='Never';
end

function schema=CreateAndConnectViewerMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_CreateAndConnectViewerMenu(cbinfo);
end

function schema=InspectSignal(cbinfo)%#ok<DEFNU>
    schema=Simulink.sdi.internal.SLMenus.visualizeSignalsContextMenu(cbinfo);
end

function schema=HighlightInSDI(cbinfo)%#ok<DEFNU>
    schema=Simulink.sdi.internal.InspectSignalBadgeContextMenu.HighlightInSDI(cbinfo);
end

function schema=SDISignalSettings(cbinfo)%#ok<DEFNU>
    schema=Simulink.sdi.internal.InspectSignalBadgeContextMenu.SDISignalSettings(cbinfo);
end

function schema=RTBadgeInsertMenu(cbinfo)%#ok<DEFNU>
    schema=SLStudio.HiddenRateTransBlkBadgeContextMenu.InsertedRTBlock(cbinfo);
end

function schema=RTBadgeHelpMenu(cbinfo)%#ok<DEFNU>
    schema=SLStudio.HiddenRateTransBlkBadgeContextMenu.InsertedRTBlockHelp(cbinfo);
end

function schema=UnitConversionInsertBlockMenu(cbinfo)%#ok<DEFNU>
    schema=SLStudio.UnitConversionBlockBadgeContextMenu.InsertBlock(cbinfo);
end

function schema=SignalPortCouplingElementParameterDialogMenu(cbinfo)%#ok<DEFNU>
    schema=SLStudio.SignalPortCouplingElementParameterDialogMenu.ShowDialog(cbinfo);
end

function schema=ConnectToExistingViewerMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_ConnectToExistingViewerMenu(cbinfo);
end

function schema=DisconnectViewerMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_DisconnectViewerMenu(cbinfo);
end

function schema=DeleteViewerMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_DeleteViewerMenu(cbinfo);
end

function schema=SignalProperties(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SignalProperties';
    schema.label=DAStudio.message('Simulink:studio:SignalProperties');
    schema.callback=@SignalPropertiesCB;
    schema.state=loc_getSignalPropertiesState(cbinfo);

    schema.autoDisableWhen='Never';
end

function state=loc_getSignalPropertiesState(cbinfo)
    state='Enabled';
    if SLStudio.Utils.isConnectionLineSelected(cbinfo)
        state='Disabled';
    else
        if SLStudio.Utils.isLockedSystem(cbinfo)
            state='Disabled';
        end
    end
end

function SignalPropertiesCB(cbinfo)

    l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
    if SLStudio.Utils.objectIsValidLine(l)
        assert(~SLStudio.Utils.isConnectionLineSelected(cbinfo),...
        'Cannot show properties for connection lines');
        srcPort=SLStudio.Utils.getLineSourcePort(l);
        portH=srcPort.handle;
    else
        obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidPort(obj)
            if strcmpi(obj.type,'Out Port')
                portH=obj.handle;
            else
                block=SLStudio.Utils.getSigGenSourceBlock(obj);
                ports=get_param(block,'PortHandles');
                portH=ports.Outport;
            end
        end
    end

    if ishandle(portH)
        set_param(portH,'OpenSigPropDialog','on');
    end
end


function schema=SignalHierarchy(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SignalHierarchy';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SignalHierarchy');
    else
        schema.icon='signalHierarchy';
    end
    schema.callback=@SignalHierarchyCB;
    strictBusMode=cbinfo.model.StrictBusMsg;

    if(strcmpi(cbinfo.userdata,'ContextMenu')&&...
        isempty(get_param(gcs,'CurrentOutputPort')))
        schema.state='Hidden';
    elseif strcmpi(strictBusMode,'None')||strcmpi(strictBusMode,'Warning')
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    schema.autoDisableWhen='Never';
end

function SignalHierarchyCB(cbinfo)
    try
        if slfeature('JavascriptSignalHierarchyViewer')
            modelHandle=cbinfo.editorModel.Handle;
            l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
            srcPort=SLStudio.Utils.getLineSourcePort(l);
            portHndl=srcPort.handle;
            Simulink.internal.BusHierarchyDialogMgr.openDialog(portHndl,modelHandle,0,0);
        else
            show(Simulink.BusHierarchyViewerWindowMgr.getDialog(cbinfo.editorModel.Name));
        end
    catch Ex %#ok

    end
end

function schema=GeneratorParameters(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalActions.act_GeneratorParameters(cbinfo);

    schema.autoDisableWhen='Never';
end

function schema=CreateAndConnectGeneratorMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_CreateAndConnectGeneratorMenu(cbinfo);
end

function schema=ConnectToExistingGeneratorMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_ConnectToExistingGeneratorMenu(cbinfo);
end

function schema=SwitchGeneratorConnectionMenu(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalMenus.menu_SwitchGeneratorConnectionMenu(cbinfo);
end

function schema=DisconnectGenerator(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalActions.act_DisconnectGenerator(cbinfo);
end

function schema=DisconnectAndDeleteGenerator(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalActions.act_DisconnectAndDeleteGenerator(cbinfo);
end

function schema=DisplayGenerator(cbinfo)%#ok<DEFNU>
    schema=Simulink.scopes.SignalActions.act_DisplayGenerator(cbinfo);
    schema.autoDisableWhen='Never';
end

function srcPorts=loc_getEnabledInPorts(block)
    srcPorts={};

    ph=get_param(block.handle,'PortHandles');
    ph=ph.Inport;
    pc=get_param(block.handle,'PortConnectivity');








    for ii=1:length(ph)
        portNumber=get_param(ph(ii),'PortNumber');
        for jj=1:length(pc)
            pcpn=str2double(pc(jj).Type);
            if(pcpn==portNumber)&&~isempty(pc(jj).SrcBlock)&&pc(jj).SrcBlock~=-1

                srcBlockPortHandles=get_param(pc(jj).SrcBlock,'PortHandles');



                srcPortIndex=pc(jj).SrcPort+1;
                if srcPortIndex<=length(srcBlockPortHandles.Outport)
                    srcPortHandle=srcBlockPortHandles.Outport(srcPortIndex);
                else
                    srcPortIndex=srcPortIndex-length(srcBlockPortHandles.Outport);
                    srcPortHandle=srcBlockPortHandles.State(srcPortIndex);
                end
                srcPortStruct=struct;
                srcPortStruct.inPortH=ph(ii);
                srcPortStruct.srcPortH=srcPortHandle;
                srcPorts=[srcPorts,srcPortStruct];%#ok<AGROW>
            end
        end
    end
end

function schema=BlockInportsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:BlockInportsMenu';
    schema.label=DAStudio.message('Simulink:studio:BlockInportsMenu');
    schema.obsoleteTags={'Simulink:BlockInputPortsMenu'};

    srcPorts={};
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        srcPorts=loc_getEnabledInPorts(block);
    end

    if~isempty(srcPorts)
        schema.state='Enabled';

        childrenFcns={};
        for ii=1:length(srcPorts)



            inPortHandle=srcPorts{ii}.inPortH;
            inPortNumber=get_param(inPortHandle,'PortNumber');
            inPortName=slInternal('getPortLabel',block.handle,inPortNumber,true);
            srcPortHandle=srcPorts{ii}.srcPortH;

            inPortTag=['Port_',num2str(inPortNumber)];
            if isempty(inPortName)
                inPortLabel=[inPortTag,'...'];
            else
                inPortLabel=[inPortTag,'( ',inPortName,' )...'];
            end

            menuItem={@BlockPortPropertiesMenuItem,{inPortTag,inPortLabel,srcPortHandle,true}};
            childrenFcns=[childrenFcns,{menuItem}];%#ok<AGROW>
        end
        schema.childrenFcns=childrenFcns;
    else
        schema.state='Disabled';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    end

    schema.autoDisableWhen='Never';
end

function schema=BlockPortPropertiesMenuItem(cbinfo)
    schema=sl_action_schema;
    schema.label=cbinfo.userdata{2};
    isInportItem=cbinfo.userdata{4};
    if isInportItem
        schema.tag=['Simulink:InPortPropertiesMenuItem_',cbinfo.userdata{1}];
    else
        schema.tag=['Simulink:OutPortPropertiesMenuItem_',cbinfo.userdata{1}];
    end
    schema.userdata=cbinfo.userdata{3};
    schema.callback=@BlockPortPropertiesCB;

    schema.autoDisableWhen='Never';
end

function BlockPortPropertiesCB(cbinfo)
    portH=cbinfo.userdata;
    if~isempty(portH)&&ishandle(portH)
        set_param(portH,'OpenSigPropDialog','on');
    end
end

function schema=BlockOutportsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:BlockOutportsMenu';
    schema.label=DAStudio.message('Simulink:studio:BlockOutportsMenu');
    schema.obsoleteTags={'Simulink:BlockOutputPortsMenu'};

    outPorts={};
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        ph=get_param(block.handle,'PortHandles');
        outPorts=ph.Outport;
    end

    if~isempty(outPorts)
        schema.state='Enabled';

        childrenFcns={};
        for ii=1:length(outPorts)
            outPortHandle=outPorts(ii);
            outPortNumber=get_param(outPortHandle,'PortNumber');
            outPortName=slInternal('getPortLabel',block.handle,outPortNumber,false);

            outPortTag=['Port_',num2str(outPortNumber)];
            if isempty(outPortName)
                outPortLabel=[outPortTag,'...'];
            else
                outPortLabel=[outPortTag,'( ',outPortName,' )...'];
            end

            menuItem={@BlockPortPropertiesMenuItem,{outPortTag,outPortLabel,outPortHandle,false}};
            childrenFcns=[childrenFcns,{menuItem}];%#ok<AGROW>
        end
        schema.childrenFcns=childrenFcns;
    else
        schema.state='Disabled';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    end

    schema.autoDisableWhen='Never';
end


function schema=PositionPorts(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:PositionPorts';
    schema.label=DAStudio.message('Simulink:dialog:FPPPositionPorts');
    schema.callback=@PositionPortsCB;

    if~slfeature('SubsystemFlexiblePortPlacement')||~slfeature('SubsystemFlexiblePortPlacementMenu')
        schema.state='Hidden';
        return;
    end

    schema.state='Disabled';
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blockH=block.handle;
        if is_simulink_handle(blockH)
            isSubsystem=strcmp(get_param(blockH,'BlockType'),'SubSystem');
            hasPorts=any(get_param(blockH,'ports')>0);
            if hasPorts&&isSubsystem
                schema.state='Enabled';
            end
        end
    end

end

function PositionPortsCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    assert(SLStudio.Utils.objectIsValidBlock(block));
    slprivate('openPositionPortsDialog',block.handle)
end

function schema=UnlockLibrary(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:UnlockLibrary';
    schema.state='Enabled';

    lockedLibrary=strcmpi(get_param(cbinfo.model.handle,'Lock'),'on');
    if lockedLibrary
        schema.label=DAStudio.message('Simulink:studio:UnlockLibrary');
        if Simulink.harness.internal.hasActiveHarness(cbinfo.model.handle)
            schema.state='Disabled';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:LibraryUnlocked');
        schema.state='Disabled';
    end
    schema.callback=@ToggleUnlockLibraryCB;
    schema.autoDisableWhen='Busy';

end

function ToggleUnlockLibraryCB(cbinfo)
    slInternal('toggleLock',cbinfo.model.handle);
end

function schema=LockLinksToLibrary(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:LockLinksToLibrary';
    schema.state='Enabled';

    lockLinksToLibrary=strcmpi(get_param(cbinfo.model.handle,'LockLinksToLibrary'),'on');
    if lockLinksToLibrary
        schema.label=DAStudio.message('Simulink:studio:UnlockLinksToLibrary');
    else
        schema.label=DAStudio.message('Simulink:studio:LockLinksToLibrary');
    end
    lockedLibrary=strcmpi(get_param(cbinfo.model.handle,'Lock'),'on');
    if lockedLibrary
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Busy';

    schema.callback=@ToggleLockLinksToLibraryCB;
end

function ToggleLockLinksToLibraryCB(cbinfo)
    slInternal('toggleLockLinksToLibrary',cbinfo.model.handle);
end

function schema=ConvertTo(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ConvertTo';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='convertSubsystem';
    else
        schema.label=DAStudio.message('Simulink:studio:ConvertTo');
    end
    if(strcmp(loc_SubsysToVSSmenuState(cbinfo),'Enabled')||...
        strcmp(loc_getConvertSubsystemToReferencedModelState(cbinfo),'Enabled')||...
        strcmp(loc_getConfigSubSystemMenuState(cbinfo),'Enabled')||...
        strcmp(loc_getConvertSubsystemToSubsystemReferenceState(cbinfo),'Enabled'))
        schema.state='Enabled';
    else
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    end
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:ConvertSubsystemToSubsystemReference')...
    ,im.getAction('Simulink:ConvertSubsystemToReferencedModel'),...
    im.getAction('Simulink:ConvertSubsysToVSS'),...
    im.getAction('Simulink:ConvertCSSToVSS'),...
    };
end

function schema=ConvertSubsysToVSS(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ConvertSubsysToVSS';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:convertToVariantSubsystemActionLabel';
        schema.icon='convertSubsystemToVariantSubsystem';
    else
        schema.label=DAStudio.message('Simulink:studio:ConvertSubsysToVSS');
    end
    schema.state=loc_SubsysToVSSmenuState(cbinfo);
    schema.callback=@SLStudio.Utils.convertSubsysToVSSCB;
end

function schema=ConvertCSSToVSS(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ConvertCSSToVSS';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='convertSubsystemToVariantSubsystem';
    else
        schema.label=DAStudio.message('Simulink:studio:ConvertCSSToVSS');
    end
    schema.state=loc_getConfigSubSystemMenuState(cbinfo);
    schema.callback=@ConvertCSSToVSSCB;
end

function ConvertCSSToVSSCB(cbinfo)

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blockH=block.handle;
        if ishandle(blockH)
            if block.isConfigurableSubsystem
                Simulink.CSStoVSSddg.Create(blockH);
            end
        end
    end

end

function schema=UnlockProtectedModel(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:UnlockProtectedModel';
    schema.label=DAStudio.message('Simulink:studio:UnlockProtectedModel');

    schema.state='Hidden';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            modelFile=get_param(block.getFullPathName,'ModelFile');
            [~,modelName,~]=fileparts(modelFile);

            is_protected=strcmp('on',get_param(block.handle,'ProtectedModel'));
            if is_protected
                [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');
                if isempty(opts)
                    schema.state='Hidden';
                else
                    is_encrypted=Simulink.ModelReference.ProtectedModel.doesProtectedModelHaveEncryptedContents(modelName);
                    if is_encrypted
                        schema.state='Enabled';
                    else
                        schema.state='Disabled';
                    end
                end
            else
                schema.state='Hidden';
            end
            schema.callback=@unlockCB;
        end
    end
end

function unlockCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            [~,modelName,~]=fileparts(get_param(block.handle,'ModelFile'));
            Simulink.ModelReference.ProtectedModel.getPasswordFromDialogForAuthorize(modelName,cbinfo.model.name);
        end
    end
end

function CreateProtectedModelCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    blockpath=block.getFullPathName;
    pm=Simulink.ModelReference.ProtectedModel.CreatorDialog(blockpath);
    if~isempty(pm)
        Simulink.ModelReference.ProtectedModel.showDialog(pm);
    end
end

function schema=DisplayProtectedModelWebview(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:DisplayProtectedModelWebview';
    schema.label=DAStudio.message('Simulink:studio:DisplayProtectedModelWebview');

    schema.state='Hidden';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            is_protected=strcmp('on',get_param(block.handle,'ProtectedModel'));
            if is_protected
                modelFile=get_param(block.getFullPathName,'ModelFile');
                [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');
                if isempty(opts)
                    schema.state='Hidden';
                elseif opts.webview
                    schema.state='Enabled';
                else
                    schema.state='Disabled';
                end
            else
                schema.state='Hidden';
            end
        end
    end
    schema.callback=@DisplayWebviewFromMenuCB;

end

function schema=DisplayProtectedModelReport(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:DisplayProtectedModelReport';
    schema.label=DAStudio.message('Simulink:studio:DisplayProtectedModelReport');

    schema.state='Hidden';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            is_protected=strcmp('on',get_param(block.handle,'ProtectedModel'));
            if is_protected
                modelFile=get_param(block.getFullPathName,'ModelFile');
                [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');

                if isempty(opts)
                    schema.state='Hidden';
                elseif opts.report
                    schema.state='Enabled';
                else
                    schema.state='Disabled';
                end
            else
                schema.state='Hidden';
            end
            schema.callback=@DisplayReportFromMenuCB;
        end

    end
end

function schema=FMUBlockSimulateUsingNativeSimulinkBehavior(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FMUBlockSimulateUsingNativeSimulinkBehavior';
    schema.label=DAStudio.message('Simulink:studio:FMUBlockSimulateUsingNativeSimulinkBehavior');
    schema.state='Enabled';
    schema.callback=@FMUBlockSimulateUsingCallback;
end

function schema=FMUBlockSimulateUsingFMU(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:FMUBlockSimulateUsingFMU';
    schema.label=DAStudio.message('Simulink:studio:FMUBlockSimulateUsingFMU');
    schema.state='Enabled';
    schema.callback=@FMUBlockSimulateUsingCallback;
end

function schema=CreateHarnessForProtectedModel(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:CreateHarnessForProtectedModel';
    schema.label=DAStudio.message('Simulink:studio:CreateHarnessForProtectedModel');

    schema.state='Hidden';

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)

        if strcmpi(get_param(block.handle,'BlockType'),'ModelReference')
            is_protected=strcmp('on',get_param(block.handle,'ProtectedModel'));
            if is_protected
                modelFile=get_param(block.getFullPathName,'ModelFile');
                [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');

                if isempty(opts)||slfeature('ProtectedModelDirectSimulation')<1
                    schema.state='Hidden';
                else
                    schema.state='Enabled';
                end
            else
                schema.state='Hidden';
            end
            schema.callback=@CreateHarnessModelFromMenuCB;
        end

    end
end

function DisplayReportFromMenuCB(cbinfo)
    topModelName=cbinfo.model.name;
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    modelFile=get_param(block.getFullPathName,'ModelFile');
    [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');
    Simulink.ModelReference.ProtectedModel.setStageDisplayReport(opts.modelName,topModelName);
end

function DisplayWebviewFromMenuCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    modelFile=get_param(block.getFullPathName,'ModelFile');
    [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');
    Simulink.ModelReference.ProtectedModel.displayWebview(opts.modelName);
end

function CreateHarnessModelFromMenuCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    modelFile=get_param(block.getFullPathName,'ModelFile');
    [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(modelFile,'runNoConsistencyChecks');
    Simulink.ModelReference.ProtectedModel.createHarness(opts.modelName);
end

function FMUBlockSimulateUsingCallback(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    CurrentFMUMode=get_param(block.getFullPathName,'SimulateUsing');
    switch(CurrentFMUMode)
    case 'FMU'
        set_param(block.getFullPathName,'SimulateUsing','Native Simulink Behavior');
    case 'Native Simulink Behavior'
        set_param(block.getFullPathName,'SimulateUsing','FMU');
    otherwise
        assert(false,'Unsupported mode for FMU with Native Simulink behavior');
    end
end


function schema=NumberOfInputPortsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    currBlockSupported=false;
    selection=cbinfo.getSelection();

    if~isempty(selection)

        scopeBlockTypes=Simulink.scopes.getSupportedBlocks('NumInputPorts');
        for indx=1:numel(scopeBlockTypes)
            if strcmpi(selection.BlockType,scopeBlockTypes{indx}(2))
                currBlockSupported=true;
                if strcmpi(selection.BlockType,'Scope')

                    currBlockSupported=~uiservices.onOffToLogical(selection.Floating);
                end
                break;
            end
        end
    end

    if(length(selection)==1)&&currBlockSupported

        schema.state='Enabled';
        schema.label=getString(message('Simulink:utility:numInputPortsLabel'));
        schema.tag='Simulink:NumberOfInputPorts';
        schema.generateFcn=@menus_spb_timescope;
    else
        schema.state='Hidden';
    end
end

function schema=ConnectorWidthMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ConnectorWidthMenu';
    schema.label=DAStudio.message('Simulink:studio:ConnectorWidthMenu');

    schema.state=loc_getConnectorWidthMenuState(cbinfo);
    schema.childrenFcns={{@loc_ConnectorWidthSchema,{'1px',1}},...
    {@loc_ConnectorWidthSchema,{'2px',2}},...
    {@loc_ConnectorWidthSchema,{'3px',3}},...
    {@loc_ConnectorWidthSchema,{'4px',4}},...
    {@loc_ConnectorWidthSchema,{'5px',5}},...
    {@loc_ConnectorWidthSchema,{'6px',6}}...
    };
end

function state=loc_getConnectorWidthMenuState(cbinfo)
    hasConnectors=SLStudio.Utils.selectionHasConnectors(cbinfo);
    if cbinfo.isContextMenu&&~hasConnectors
        state='Hidden';
    else
        state='Disabled';
    end

    if~SLStudio.Utils.isLockedSystem(cbinfo)
        if hasConnectors
            state='Enabled';
        end
    end
end

function schema=loc_ConnectorWidthSchema(cbinfo)
    label=cbinfo.userdata{1};
    ConnectorWidth=cbinfo.userdata{2};

    schema=sl_action_schema;
    schema.label=DAStudio.message(['Simulink:studio:ConnectorWidth',label]);

    schema.userdata.ConnectorWidth=ConnectorWidth;
    schema.callback=@SetConnectorWidthCB;
    schema.tag=['Simulink:ConnectorWidth',label];
    schema.icon=['Simulink:ConnectorWidth',label];
    schema.state=loc_getConnectorWidthMenuState(cbinfo);
end

function SetConnectorConnectorWidth(connectors,ConnectorWidth)
    if~isempty(connectors)
        for index=1:length(connectors)
            connectors(index).strokeWidth=ConnectorWidth;
        end
    end
end

function SetConnectorWidthCB(cbinfo)
    ConnectorWidth=cbinfo.userdata.ConnectorWidth;


    connectors=SLStudio.Utils.partitionSelectionOf(cbinfo,'connectors');

    if~isempty(connectors)
        editor=cbinfo.studio.App.getActiveEditor;
        editor.createMCommand('Simulink:studio:SetConnectorWidthCommand',DAStudio.message('Simulink:studio:SetConnectorWidthCommand'),@SetConnectorConnectorWidth,{connectors,ConnectorWidth});
    end
end







