function config=architectureSingleSelectionActionConfig()

































    config=[
    struct('name','ZC.SpotlightSelectedComponent',...
    'icon','/toolbox/shared/dastudio/resources/ARCHITECTURE/spotlightSSA.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/ARCHITECTURE/spotlightSSASelected.svg',...
    'checker',@CanCreateSpotlight,...
    'handler',@CreateSpotlightFromSelection,...
    'tooltip',DAStudio.message('SystemArchitecture:studio:OpenSpotlightMenuItem'),...
    'priority','normal'),...
    struct('name','ZC.SaveAsArchitecture',...
    'icon','/toolbox/shared/dastudio/resources/ARCHITECTURE/saveAsArchitecture.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/ARCHITECTURE/saveAsArchitectureSelected.svg',...
    'checker',@CanSaveAsArchitecture,...
    'handler',@SaveAsArchitecture,...
    'tooltip',DAStudio.message('SystemArchitecture:SaveAndLink:SaveAsArchitectureName'),...
    'priority','normal'),...
    struct('name','ZC.LinkToModel',...
    'icon','/toolbox/shared/dastudio/resources/ARCHITECTURE/linkToModel.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/ARCHITECTURE/linkToModelSelected.svg',...
    'checker',@CanLinkComponentToModel,...
    'handler',@LinkComponentToModel,...
    'tooltip',DAStudio.message('SystemArchitecture:SaveAndLink:LinkToModelName'),...
    'priority','normal'),...
    struct('name','SL.SSA.Route',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-16.svg',...
    'checker',@MACanRoute,...
    'handler',@MARoute,...
    'tooltip',DAStudio.message('Simulink:studio:MARoute'),...
    'priority','normal'),...
    struct('name','SL.SSA.RouteSegmentsOfBlock',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',...
    'checker',@MACanRouteSegmentsOfBlock,...
    'handler',@MARouteSegmentsOfBlock,...
    'tooltip',DAStudio.message('Simulink:studio:MARouteLines'),...
    'priority','normal'),...
    struct('name','SL.SSA.InjectSignal',...
    'icon','/toolbox/shared/simulinktest/resources/icons/injector-quickaction.png',...
    'hoverIcon','/toolbox/shared/simulinktest/resources/icons/injector-quickaction-highlight.png',...
    'checker',@MACanFaultSignal,...
    'handler',@MAAddFaultOnSignal,...
    'tooltip',DAStudio.message('Simulink:studio:MAFaultSignal'),...
    'priority','normal'),...
    struct('name','SL.SSA.InjectBlock',...
    'icon','/toolbox/shared/simulinktest/resources/icons/injector-quickaction.png',...
    'hoverIcon','/toolbox/shared/simulinktest/resources/icons/injector-quickaction-highlight.png',...
    'checker',@MACanFaultBlock,...
    'handler',@MAAddFaultOnBlock,...
    'tooltip',DAStudio.message('Simulink:studio:MAFaultBlock'),...
    'priority','normal'),...
    struct('name','SL.SSA.HighlightSignalToSrc',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-src-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-src-16.svg',...
    'checker',@SSA_CanHighlightSignalToSrc,...
    'handler',@SSA_HighlightSignalToSrc,...
    'tooltip',DAStudio.message('Simulink:studio:SSA_HighlightSignalToSource'),...
    'priority','normal'),...
    struct('name','SL.SSA.HighlightSignalToDst',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-dst-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-highlight-signal-to-dst-16.svg',...
    'checker',@SSA_CanHighlightSignalToDst,...
    'handler',@SSA_HighlightSignalToDst,...
    'tooltip',DAStudio.message('Simulink:studio:SSA_HighlightSignalToDestination'),...
    'priority','normal'),...
    struct('name','EditTime.SignalError',...
    'icon','/toolbox/shared/dastudio/resources/error_16.png',...
    'hoverIcon','/toolbox/shared/dastudio/resources/error_16.png',...
    'checker',@MAHasEditTimeIssueSignalError,...
    'handler',@MAEditTimeIssueSignalErrorPopup,...
    'tooltip',@MAEditTimeIssueSignalErrorTooltip,...
    'priority','alert'),...
    struct('name','EditTime.SignalWarn',...
    'icon','/toolbox/shared/dastudio/resources/warning_16.png',...
    'hoverIcon','/toolbox/shared/dastudio/resources/warning_16.png',...
    'checker',@MAHasEditTimeIssueSignalWarn,...
    'handler',@MAEditTimeIssueSignalWarnPopup,...
    'tooltip',@MAEditTimeIssueSignalWarnTooltip,...
    'priority','alert'),...
    struct('name','SL.SSA.AddComment',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',...
    'checker',@canShowCommentIcon,...
    'handler',@ShowComment,...
    'tooltip',DAStudio.message('designreview_comments:Command:AddCommentSingleSelect'),...
    'priority','normal'),...
    struct('name','Error',...
    'icon','/toolbox/shared/dastudio/resources/error_16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/error_16.svg',...
    'checker',@MAIsEditTimeError,...
    'handler',@MAEditTimeIssueErrorPopup,...
    'tooltip',@MAEditTimeIssueErrorTooltip,...
    'priority','alert'),...
    struct('name','Warning',...
    'icon','/toolbox/shared/dastudio/resources/warning_16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/warning_16.svg',...
    'checker',@MAIsEditTimeWarning,...
    'handler',@MAEditTimeIssueWarningPopup,...
    'tooltip',@MAEditTimeIssueWarningTooltip,...
    'priority','alert'),...



    ];
end


function result=CanCreateSpotlight(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        any(strcmpi(get_param(m3iBlk.handle,'BlockType'),{'subsystem','ModelReference'}));
    end
end

function CreateSpotlightFromSelection(editor,m3iBlk,~)
    if CanCreateSpotlight(editor,m3iBlk)
        selectedBlk.handle=m3iBlk.handle;
        currentStudio=editor.getStudio;
        ZCStudio.ArchitectureMenu('createSpotlight',selectedBlk,currentStudio.getStudioTag);
    end
end


function result=CanSaveAsArchitecture(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        systemcomposer.internal.validator.ConversionUIValidator.canSaveAsArchitecture(m3iBlk.handle);
    end
end

function SaveAsArchitecture(editor,m3iBlk,~)
    if CanSaveAsArchitecture(editor,m3iBlk)
        selectedBlk.Handle=m3iBlk.handle;
        systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch({selectedBlk.Handle},1);
    end
end

function result=CanLinkComponentToModel(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        systemcomposer.internal.validator.ConversionUIValidator.canLinkToModel(m3iBlk.handle);
    end
end

function LinkComponentToModel(editor,m3iBlk,~)
    if CanLinkComponentToModel(editor,m3iBlk)
        selectedBlk.Handle=m3iBlk.handle;
        systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch({selectedBlk.Handle},3);
    end
end


function result=MACanRoute(editor,element)
    result=false;

    if editor.isLocked
        return;
    end

    if loc_isSegmentValidForActions(element)&&...
        SLM3I.Util.isValidDiagramElement(element)&&...
        ~loc_insideVariantSS(element.container)
        result=true;
    end
end

function MARoute(editor,element,~)
    if MACanRoute(editor,element)
        SLM3I.SLDomain.routeSegment(editor,element);
    end
end


function result=MACanRouteSegmentsOfBlock(editor,element)
    result=false;

    if~builtin('slf_feature','get','ChannelRoutingActions')
        return;
    end

    if editor.isLocked
        return;
    end

    if isa(element,'SLM3I.Block')&&SLM3I.Util.isValidDiagramElement(element)&&~loc_insideVariantSS(element)
        if element.type~="Inport"&&element.type~="Outport"
            if~element.outputPort.isEmpty
                result=true;
            elseif~element.inputPort.isEmpty

                for i=1:element.inputPort.size
                    ph=element.inputPort.at(i).handle;
                    if strcmp(get_param(ph,'IsHidden'),'off')
                        result=true;
                        break;
                    end
                end
            end
        end

    end
end

function MARouteSegmentsOfBlock(editor,element,~)
    if MACanRouteSegmentsOfBlock(editor,element)
        SLM3I.SLDomain.routeSegmentsOfBlock(editor,element);
    end
end


function result=MACanFaultSignal(editor,element)
    result=false;

    if~builtin('slf_feature','get','SLTInjector')||...
        ~loc_isSegmentValidForFaults(element)
        return;
    end

    model=get(bdroot(editor.getDiagram.handle),'object');
    if isa(element,'SLM3I.Segment')&&SLM3I.Util.isValidDiagramElement(element)&&~SLM3I.SLDomain.isBdContainingGraphCompiled(model.handle)
        port=SLStudio.internal.actions.findSegmentOutputPort(element);
        if isa(port,'SLM3I.Port')&&SLM3I.Util.isValidDiagramElement(port)&&strcmp(get_param(port.handle,'PortType'),'outport')
            result=true;
        end
    end
end

function MAAddFaultOnSignal(editor,element,~)
    port=SLStudio.internal.actions.findSegmentOutputPort(element);
    if port.handle~=-1&&strcmp(get_param(port.handle,'PortType'),'outport')
        topModelHandle=editor.getStudio().App.blockDiagramHandle;
        safety.gui.dialog.createFaultDialog.create(topModelHandle,port.handle);
    end
end

function result=MACanFaultBlock(editor,element)
    result=false;

    if~builtin('slf_feature','get','SLTBlockInjector')
        return;
    end

    model=get(bdroot(editor.getDiagram.handle),'object');
    if isa(element,'SLM3I.Block')&&SLM3I.Util.isValidDiagramElement(element)&&~SLM3I.SLDomain.isBdContainingGraphCompiled(model.handle)...
        &&(element.isModelReference||element.isSubsystem)
        portHandles=get_param(element.handle,'PortHandles');
        prtArrayOut=[portHandles.Outport,portHandles.State];
        if~isempty(prtArrayOut)
            result=true;
        end
    end
end

function MAAddFaultOnBlock(editor,element,~)
    topModelHandle=editor.getStudio().App.blockDiagramHandle;
    safety.gui.dialog.createFaultDialog.create(topModelHandle,element.handle);
end


function result=SSA_CanHighlightSignalToSrc(~,element)
    result=SSA_CanHighlightSignal(element);
end

function result=SSA_CanHighlightSignalToDst(~,element)
    result=SSA_CanHighlightSignal(element);
end

function result=SSA_CanHighlightSignal(element)
    if~loc_isSegmentValidForActions(element)||...
        get_param(bdroot(element.handle),'ModelSlicerActive')
        result=false;
        return
    end

    result=strcmpi(get_param(element.handle,'LineType'),'signal');
end

function result=canShowCommentIcon(editor,element,~)
    result=false;
    if(slfeature('DesignReview_Comments')>0&&simulink.designreview.DesignReviewApp.getInstance().isCommentsAppOpen(bdroot(editor.getName)))
        if(isa(element,'SLM3I.Block')...
            &&SLM3I.Util.isValidDiagramElement(element)...
            &&simulink.designreview.Util.isCommentsSupportedInEditor(editor))
            result=true;
        end
    end
end

function ShowComment(editor,~,~)
    blk=simulink.designreview.Util.getSelectedBlock(editor);
    model=get_param(editor.getStudio.App.blockDiagramHandle,'Name');
    simulink.designreview.CommentsApi.addCommentForSingleSelect(model,blk);
end

function SSA_HighlightSignalToSrc(~,element,~)
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToSource(element.handle);
end

function SSA_HighlightSignalToDst(~,element,~)
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToDestination(element.handle);
end

function result=MAHasEditTimeIssueSignalError(~,element)
    result=false;
    if~SLM3I.Util.isValidDiagramElement(element)
        return;
    end
    if isa(element,'SLM3I.Segment')
        stylerName='MathWorks.EditTimeCheckingStyler';
        styler=diagram.style.getStyler(stylerName);
        if isempty(styler)
            return;
        end

        if(styler.hasClass(element.handle,'Error'))
            result=true;
        else
            result=false;
        end
    end

end

function MAEditTimeIssueSignalErrorPopup(editor,element,~)
    edittime.util.showBlockViolations(bdroot(editor.getName),element.handle,ModelAdvisor.CheckStatus.Failed);
end

function tooltip=MAEditTimeIssueSignalErrorTooltip(editor,element,~)
    tooltip=edittime.util.getTooltip(bdroot(editor.getName),element.handle);
end

function result=MAHasEditTimeIssueSignalWarn(~,element)
    result=false;
    if~SLM3I.Util.isValidDiagramElement(element)
        return;
    end
    if isa(element,'SLM3I.Segment')
        stylerName='MathWorks.EditTimeCheckingStyler';
        styler=diagram.style.getStyler(stylerName);
        if isempty(styler)
            return;
        end

        if(styler.hasClass(element.handle,'Warn'))
            result=true;
        else
            result=false;
        end
    end
end

function MAEditTimeIssueSignalWarnPopup(editor,element,~)
    edittime.util.showBlockViolations(bdroot(editor.getName),element.handle,ModelAdvisor.CheckStatus.Warning);
end

function tooltip=MAEditTimeIssueSignalWarnTooltip(editor,element,~)
    tooltip=edittime.util.getTooltip(bdroot(editor.getName),element.handle);
end


function result=MAIsEditTimeWarning(~,element)
    if~SLM3I.Util.isValidDiagramElement(element)
        result=false;
        return;
    end

    result=false;
    if isa(element,'SLM3I.Block')
        stylerName='MathWorks.EditTimeCheckingStyler';
        styler=diagram.style.getStyler(stylerName);
        if isempty(styler)
            return;
        end

        if(styler.hasClass(element.handle,'Warn'))
            result=true;
        else
            result=false;
        end
    end
end

function result=MAIsEditTimeError(~,element)
    if~SLM3I.Util.isValidDiagramElement(element)
        result=false;
        return;
    end

    result=false;
    if isa(element,'SLM3I.Block')
        stylerName='MathWorks.EditTimeCheckingStyler';
        styler=diagram.style.getStyler(stylerName);
        if isempty(styler)
            return;
        end

        if(styler.hasClass(element.handle,'Error'))
            result=true;
        else
            result=false;
        end
    end
end

function MAEditTimeIssueWarningPopup(editor,element,position)
    MAEditTimeIssuePopup(editor,element,position,ModelAdvisor.CheckStatus.Warning);
end

function tooltip=MAEditTimeIssueWarningTooltip(editor,element,~)
    tooltip=MAEditTimeIssueTooltip(editor,element,ModelAdvisor.CheckStatus.Warning);
end

function MAEditTimeIssueErrorPopup(editor,element,position)
    MAEditTimeIssuePopup(editor,element,position,ModelAdvisor.CheckStatus.Failed);
end

function tooltip=MAEditTimeIssueErrorTooltip(editor,element,~)
    tooltip=MAEditTimeIssueTooltip(editor,element,ModelAdvisor.CheckStatus.Failed);
end

function tooltip=MAEditTimeIssueTooltip(editor,element,type)
    tooltip=edittime.util.getTooltip(bdroot(editor.getName),element.handle,type);
end

function MAEditTimeIssuePopup(editor,element,~,type)
    edittime.util.showBlockViolations(bdroot(editor.getName),element.handle,type);
end



function result=loc_insideVariantSS(element)
    result=false;

    ssBlock=element.container.getOwningBlock;
    if ssBlock.isvalid&&(ssBlock.getSubsystemType==SLM3I.SubsystemType.VARIANT)
        result=true;
    end
end
function result=loc_isSegmentValidForActions(element)

    result=isa(element,'SLM3I.Segment');
    if result
        if isa(element.srcElement,'SLM3I.Port')
            if(element.srcElement.container.type=="Inport"||...
                element.srcElement.container.type=="Outport")
                result=false;
            end
        end
        if isa(element.dstElement,'SLM3I.Port')
            if(element.dstElement.container.type=="Inport"||...
                element.dstElement.container.type=="Outport")
                result=false;
            end
        end
    end
end

function result=loc_isSegmentValidForFaults(element)


    result=isa(element,'SLM3I.Segment');
    if result
        if isa(element.srcElement,'SLM3I.Port')
            if(element.srcElement.container.type=="Inport"||...
                element.srcElement.container.type=="Outport")
                result=false;
            end
        end
    end
end


