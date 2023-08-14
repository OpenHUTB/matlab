function schema=ContextMenuItems(fncname,cbinfo)




    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function schema=BlockExplore(~)%#ok<*DEFNU>
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockExploreStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockExploreToolTip');
    schema.tag='Simulink:BlockExplore';
    schema.label=DAStudio.message('Simulink:studio:BlockExplore');
    schema.callback=@BlockExploreCB;

    schema.autoDisableWhen='Never';
end

function BlockExploreCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        h=block.handle;
        if block.isStateflow
            chartID=sfprivate('block2chart',block.handle);
            h=idToHandle(sfroot,chartID);
        end
        daexplr('view',h);
    else
        daexplr('view',cbinfo.uiObject);
    end
end

function schema=BlockOpen(cbinfo)
    schema=sl_action_schema;
    schema.statustip=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:BlockOpenStatusTip');
    schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:BlockOpenToolTip');
    schema.tag='Simulink:BlockOpen';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        if feature('openMLFBInSimulink')
            schema.icon='model';
            schema.label=DAStudio.message('simulink_ui:studio:resources:OpenMLFBInSimulinkActionText');
        else
            schema.icon='matlabDocument';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:BlockOpen');
    end
    schema.userdata=cbinfo.studio.App.getEditorOpenType;
    if(~isEmpty(cbinfo.selection))
        schema.state=SLStudio.Utils.getBlockOpenState(cbinfo,false);
    end

    schema.callback=@OpenBlockCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenInNewWindow(cbinfo)
    schema=sl_action_schema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowToolTip');
    schema.tag='Simulink:BlockOpenInNewWindow';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewWindow');
    schema.userdata='NEW_WINDOW';
    schema.state=SLStudio.Utils.getBlockOpenInNewWindowState(cbinfo,true);
    schema.callback=@OpenBlockMaskCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenInNewTab(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewTabStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewTabToolTip');
    schema.tag='Simulink:BlockOpenInNewTab';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewTab');
    schema.userdata='NEW_TAB';
    schema.state=SLStudio.Utils.getBlockOpenInNewTabState(cbinfo,true);
    schema.callback=@OpenBlockMaskCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenModelReference(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenToolTip');
    schema.tag='Simulink:ModelBlockOpenModelReference';
    schema.label=DAStudio.message('Simulink:studio:BlockOpen');
    schema.userdata=cbinfo.studio.App.getEditorOpenType;
    schema.state=SLStudio.Utils.getModelReferenceOpenState(cbinfo,false,'OPEN');

    schema.callback=@OpenBlockCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenModelReferenceInNewWindow(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowToolTip');
    schema.tag='Simulink:ModelBlockOpenModelReferenceInNewWindow';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewWindow');
    schema.userdata='NEW_WINDOW';
    schema.state=SLStudio.Utils.getModelReferenceOpenState(cbinfo,true,'WINDOW');
    schema.callback=@OpenBlockMaskCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenModelReferenceInNewTab(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewTabStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewTabToolTip');
    schema.tag='Simulink:ModelBlockOpenModelReferenceInNewTab';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewTab');
    schema.userdata='NEW_TAB';
    schema.state=SLStudio.Utils.getModelReferenceOpenState(cbinfo,true,'TAB');
    schema.callback=@OpenBlockMaskCB;

    schema.autoDisableWhen='Never';
end

function schema=BlockOpenModelReferenceAsRoot(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRootStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRootToolTip');
    schema.tag='Simulink:ModelBlockOpenModelReferenceAsRoot';
    schema.label=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRoot');
    schema.state=SLStudio.Utils.getModelReferenceOpenState(cbinfo,true,'TOP');
    schema.callback=@OpenModelBlockAsRootCB;

    schema.autoDisableWhen='Never';
end

function CanvasOpenModelReferenceAsRootCB(cbinfo)
    handle=SLStudio.Utils.getOneMenuTarget(cbinfo).handle;
    obj=get_param(handle,'Object');
    open_system(obj.getFullName);
end

function schema=CanvasOpenModelReferenceAsRoot(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRootStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRootToolTip');
    schema.tag='Simulink:CanvasOpenModelReferenceAsRoot';
    schema.label=DAStudio.message('Simulink:studio:ModelBlockOpenModelReferenceAsRoot');
    if(strcmp(cbinfo.editorModel.Name,cbinfo.model.Name))
        schema.state='Hidden';
    end
    schema.callback=@CanvasOpenModelReferenceAsRootCB;

    schema.autoDisableWhen='Never';
end

function OpenModelBlockAsRootCB(cbinfo)
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(target)&&target.isModelReference
        mdl=get_param(target.handle,'ModelName');
        open_system(mdl);
    end
end

function OpenBlockCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(target)
        openReq=SLM3I.BlockOpenRequest(target.handle,cbinfo.userdata,false);
        hid=GLUE2.HierarchyId();
        slStudioApp.processOpenRequest(openReq,hid);
    end
end

function OpenBlockMaskCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(target)
        openReq=SLM3I.BlockOpenRequest(target.handle,cbinfo.userdata,true);
        hid=GLUE2.HierarchyId();
        slStudioApp.processOpenRequest(openReq,hid);
    end
end




function schema=ModelBrowserBlockOpen(cbinfo)

    schema=sl_action_schema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenToolTip');
    schema.tag='Simulink:ModelBrowserBlockOpen';
    schema.label=DAStudio.message('Simulink:studio:BlockOpen');
    schema.userdata=cbinfo.studio.App.getEditorOpenType;
    schema.state=SLStudio.Utils.getBlockOpenState(cbinfo,true);
    schema.callback=@OpenBlockMBCB;

    schema.autoDisableWhen='Never';
end

function schema=ModelBrowserBlockOpenInNewWindow(cbinfo)
    schema=sl_action_schema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewWindowToolTip');
    schema.tag='Simulink:ModelBrowserBlockOpenInNewWindow';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewWindow');
    schema.userdata='NEW_WINDOW';
    schema.state=SLStudio.Utils.getBlockOpenInNewWindowState(cbinfo,true);
    schema.callback=@OpenBlockMBCB;

    schema.autoDisableWhen='Never';
end

function schema=ModelBrowserBlockOpenInNewTab(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:studio:BlockOpenInNewTabStatusTip');
    schema.tooltip=DAStudio.message('Simulink:studio:BlockOpenInNewTabToolTip');
    schema.tag='Simulink:ModelBrowserBlockOpenInNewTab';
    schema.label=DAStudio.message('Simulink:studio:BlockOpenInNewTab');
    schema.userdata='NEW_TAB';
    schema.state=SLStudio.Utils.getBlockOpenInNewTabState(cbinfo,true);
    schema.callback=@OpenBlockMBCB;

    schema.autoDisableWhen='Never';
end

function schema=ModelBrowserBlockOpenModelReference(cbinfo)
    schema=BlockOpenModelReference(cbinfo);
    schema.callback=@OpenBlockMBCB;
    schema.tag='Simulink:ModelBrowserBlockOpenModelReference';
end

function schema=ModelBrowserBlockOpenModelReferenceInNewWindow(cbinfo)
    schema=BlockOpenModelReferenceInNewWindow(cbinfo);
    schema.callback=@OpenBlockMBCB;
    return;
end

function schema=ModelBrowserBlockOpenModelReferenceInNewTab(cbinfo)
    schema=BlockOpenModelReferenceInNewTab(cbinfo);
    schema.callback=@OpenBlockMBCB;
    return;
end

function OpenBlockMBCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(target)


        maskBlockOpen=true;
        openReq=SLM3I.BlockOpenRequest(target.handle,cbinfo.userdata,maskBlockOpen);
        hid=cbinfo.targetHID;
        slStudioApp.processOpenRequest(openReq,hid);
    elseif SLStudio.Utils.objectIsValidDiagram(target)
        openTopDiagram=SLM3I.TopDiagramOpenRequest(target,cbinfo.userdata);
        hid=GLUE2.HierarchyId();
        slStudioApp.processOpenRequest(openTopDiagram,hid);
    end
end


function schema=BlockConnect(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.statustip=DAStudio.message('Simulink:editor:ContextMenuItemFlybyStr_ConnectBlocks');
    schema.tooltip=DAStudio.message('Simulink:editor:ContextMenuItemTooltipStr_ConnectBlocks');
    schema.tag='Simulink:ConnectBlocks';
    schema.label=DAStudio.message('Simulink:studio:ConnectBlocks');
    clickedBlk=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~SLStudio.Utils.objectIsValidBlock(clickedBlk)||...
        ~cbinfo.queryMenuAttribute('Simulink:ConnectBlocks','enabled',clickedBlk.handle)
        schema.state='Disabled';
    end
    schema.callback=@ConnectBlockCB;
end

function ConnectBlockCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    clickedBlk=SLStudio.Utils.getOneMenuTarget(cbinfo);
    srcBlks=editor.getSelection;

    if SLStudio.Utils.selectionHasBlocks(cbinfo)&&SLStudio.Utils.isValidBlockHandle(clickedBlk.handle)
        cbinfo.domain.autoConnectBlks(editor,clickedBlk,srcBlks);
    end

end

function schema=DeleteSegmentLabel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:DeleteSegmentLabel';
    schema.label=DAStudio.message('Simulink:studio:DeleteSegmentLabel');

    clickedLabel=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~SLStudio.Utils.objectIsValidSegmentLabel(clickedLabel)
        schema.state='Disabled';
    end

    schema.callback=@DeleteSegmentLabelCB;
    schema.userdata={cbinfo.studio.App.getActiveEditor,clickedLabel};
end

function DeleteSegmentLabelCB(cbinfo)
    cbinfo.domain.deleteLabel(cbinfo.userdata{1},cbinfo.userdata{2});
end

function schema=CopySegmentLabel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:CopySegmentLabel';
    schema.label=DAStudio.message('Simulink:studio:CopySegmentLabel');

    clickedLabel=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~SLStudio.Utils.objectIsValidSegmentLabel(clickedLabel)
        schema.state='Disabled';
    end

    schema.callback=@CopySegmentLabelCB;
end

function CopySegmentLabelCB(cbinfo)
    clickedLabel=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSegmentLabel(clickedLabel)
        cbinfo.domain.copyLabel(cbinfo.studio.App.getActiveEditor,clickedLabel);
    end
end

function schema=AnnotationChangeCategory(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:AnnotationChangeCategory';
    schema.label=DAStudio.message('Simulink:studio:ConvertToMarkup');
    category='markup';

    markupVisible=SLStudio.MarkupStyleSheet.isMarkupVisible(cbinfo.model.handle);

    clickedAnnotation=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~SLStudio.Utils.objectIsValidAnnotation(clickedAnnotation)
        schema.state='Disabled';
    end

    isMarkup=loc_annotationIsMarkup(clickedAnnotation);
    if isMarkup
        schema.label=DAStudio.message('Simulink:studio:ConvertToModel');
        category='model';
    end

    schema.callback=@AnnotationChangeCategoryCB;
    schema.userdata={cbinfo.studio.App.getActiveEditor,clickedAnnotation,category};
    if~markupVisible&&~isMarkup
        schema.tooltip=DAStudio.message('Simulink:studio:ConvertToHiddenMarkup');
    end
end

function isMarkup=loc_annotationIsMarkup(clickedAnnotation)
    isMarkup=false;
    if(strcmp(clickedAnnotation.category,'markup'))
        isMarkup=true;
    end
end

function command_changeAnnotationCategory(editor,annotation,category)
    diagram=editor.getDiagram;
    model=diagram.model;

    rootDeviant=model.asDeviant(model.getRootDeviant);
    diagramRD=diagram.asDeviant(rootDeviant);
    annotationRD=annotation.asDeviant(rootDeviant);








    rootDeviant.beginTransaction;
    if(strcmp(annotationRD.category,'markup'))
        annotationRD.category='model';
        for i=1:annotationRD.connector.size()
            connector=annotationRD.connector.at(i);
            otherEnd=connector.srcElement;
            if(connector.srcElement==annotationRD)
                otherEnd=connector.dstElement;
            end
            if(strcmp(class(otherEnd),'SLM3I.Annotation'))
                if(strcmp(otherEnd.category,'model'))

                    connector.category='model';
                end
            else

                connector.category='model';
            end
        end
    else
        annotationRD.category='markup';
        for i=1:annotationRD.connector.size()
            connector=annotationRD.connector.at(i);
            connector.category='markup';
        end
    end
    rootDeviant.commitTransaction;
end

function AnnotationChangeCategoryCB(cbinfo)
    editor=cbinfo.userdata{1};
    annotation=cbinfo.userdata{2};
    category=cbinfo.userdata{3};

    editor.createMCommand('Simulink:studio:SLChangeMarkupCategory',DAStudio.message('Simulink:studio:SLChangeMarkupCategory'),@command_changeAnnotationCategory,{editor,annotation,category});
end

function schema=AnnotationToRequirement(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:AnnotationToRequirement';
    schema.label=DAStudio.message('Slvnv:slreq:ConvertToRequirement');

    schema.callback=@AnnotationToRequirementCB;

    if~dig.isProductInstalled('Requirements Toolbox')...
        ||~slreq.utils.isInPerspective(cbinfo.studio.App.blockDiagramHandle)
        schema.state='Hidden';
        return;
    end

    selections=cbinfo.getSelection;
    hasAnnotations=false;
    for n=1:length(selections)
        selection=selections(n);
        if isa(selection,'Simulink.Annotation')
            m3iObj=SLM3I.SLDomain.handle2DiagramElement(selection.Handle);
            if~strcmp(m3iObj.Type.toString,'AREA_ANNOTATION')...
                &&~strcmp(m3iObj.Type.toString,'IMAGE_ANNOTATION')
                hasAnnotations=true;
                break;
            end
        end
    end
    if~hasAnnotations
        schema.state='Hidden';
    end
end

function AnnotationToRequirementCB(cbinfo)
    slreq.internal.AnnotationConversionHandler.menuCallback(cbinfo);
end

function state=loc_getBlockParametersState(cbinfo)
    state='Disabled';
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(obj)
        state='Enabled';
    end
end

function schema=VariantBlockParameters(cbinfo)











    schema=sl_action_schema;
    schema.tag='Simulink:VariantBlockParameters';
    item=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    blkType='';
    isSimulinkFunction=false;
    isIRTSubsystem=false;
    if(~isempty(item))
        type=get_param(item.handle,'BlockType');
        if strcmpi(type,'SubSystem')
            isSimulinkFunction=slInternal('isSimulinkFunction',item.handle);
            isIRTSubsystem=slInternal('isInitTermOrResetSubsystem',item.handle);
            if isSimulinkFunction
                type='Function-call';
            elseif isIRTSubsystem
                type='EventListener';
            else
                type='Subsystem';
            end
        end
        blkType=['(',type,')'];
    end
    schema.label=DAStudio.message('Simulink:studio:BlockParameters',blkType);
    schema.state=loc_getBlockParametersState(cbinfo);
    if isSimulinkFunction
        schema.callback=@FcnCallPortBlockParametersCB;
    elseif isIRTSubsystem
        schema.callback=@EventListenerBlockParametersCB;
    else
        schema.callback=@BlockParametersCB;
    end

    schema.autoDisableWhen='Never';
end

function BlockParametersCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        open_system(block.handle,'parameter');
    end
end

function FcnCallPortBlockParametersCB(cbinfo)
    sysBlock=SLStudio.Utils.getOneMenuTarget(cbinfo);
    block=find_system(sysBlock.handle,'SearchDepth',1,'FindAll','On',...
    'FollowLinks','On','LookUnderMasks','All','BlockType','TriggerPort');
    if~isempty(block)
        open_system(block,'parameter');
    end
end

function schema=InsertSignalExtrapolation(cbinfo)
    schema=Simulink.cosimservice.SLMenus.insertSignalExtrapolationContextMenu(cbinfo);
end

function EventListenerBlockParametersCB(cbinfo)
    sysBlock=SLStudio.Utils.getOneMenuTarget(cbinfo);
    block=find_system(sysBlock.handle,'SearchDepth',1,'FindAll','On',...
    'FollowLinks','On','LookUnderMasks','All','BlockType','EventListener');
    if~isempty(block)
        open_system(block,'parameter');
    end
end

function state=loc_getSROpenChildModelState(cbinfo)
    state='Hidden';
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end


    block_type=get_param(block.handle,'BlockType');
    if(~strcmp(block_type,'SubSystem'))
        return;
    end


    child_model=get_param(block.handle,'ReferencedSubsystem');
    if(~isempty(child_model))
        state='Enabled';
    end

end

function SROpenChildModelCB(cbinfo)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end
    child_model=get_param(block.handle,'ReferencedSubsystem');
    if~isempty(child_model)
        open_system(child_model);
    end

end

function schema=SROpenChildModel(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SROpenChildModel';
    schema.label=DAStudio.message(...
    'Simulink:SubsystemReference:OpenReferencedSubsysMenuText');
    schema.state=loc_getSROpenChildModelState(cbinfo);
    schema.callback=@SROpenChildModelCB;
    schema.autoDisableWhen='Never';
end


