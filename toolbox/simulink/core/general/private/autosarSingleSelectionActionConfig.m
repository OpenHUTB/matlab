function config=autosarSingleSelectionActionConfig()

































    config=[
    struct('name','autosar.createModel',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/createModel.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/createModelSelected.svg',...
    'checker',@CanCreateModelForComp,...
    'handler',@CreateModelForComp,...
    'tooltip',DAStudio.message('autosarstandard:editor:CreateModelMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.saveAsArchitectureModel',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/createModel.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/createModelSelected.svg',...
    'checker',@CanSaveCompositionAsArchModel,...
    'handler',@SaveCompositionAsArchModel,...
    'tooltip',DAStudio.message('autosarstandard:editor:SaveAsArchitectureModelMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.LinkToModel',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/linkToModel.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/linkToModelSelected.svg',...
    'checker',@CanLinkCompToModel,...
    'handler',@LinkCompToModel,...
    'tooltip',DAStudio.message('autosarstandard:editor:LinkToModelMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.ImportComponentFromARXML',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/importFromARXML.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/importFromARXMLSelected.svg',...
    'checker',@CanImportComponentFromARXML,...
    'handler',@ImportComponentFromARXML,...
    'tooltip',DAStudio.message('autosarstandard:editor:ImportComponentFromARXMLMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.ExportComponent',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/exportToARXML.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/exportToARXMLSelected.svg',...
    'checker',@CanExportComponent,...
    'handler',@ExportComponent,...
    'tooltip',DAStudio.message('autosarstandard:editor:ExportComponentMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.ImportCompositionFromARXML',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/importFromARXML.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/importFromARXMLSelected.svg',...
    'checker',@CanImportCompositionFromARXML,...
    'handler',@ImportCompositionFromARXML,...
    'tooltip',DAStudio.message('autosarstandard:editor:ImportCompositionFromARXMLMarqueeAction'),...
    'priority','normal'),...
    struct('name','autosar.ExportComposition',...
    'icon','/toolbox/shared/dastudio/resources/AUTOSAR/exportToARXML.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/AUTOSAR/exportToARXMLSelected.svg',...
    'checker',@CanExportComposition,...
    'handler',@ExportComposition,...
    'tooltip',DAStudio.message('autosarstandard:editor:ExportCompositionMarqueeAction'),...
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
    struct('name','SL.SSA.AddComment',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-add-comment16.svg',...
    'checker',@canShowCommentIcon,...
    'handler',@ShowComment,...
    'tooltip','Add Comment',...
    'priority','normal'),...



    ];
end


function result=CanCreateModelForComp(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        autosar.composition.Utils.isCompBlockNonLinked(m3iBlk.handle)&&...
        autosar.composition.Utils.isComponentBlock(m3iBlk.handle);
    end
end

function CreateModelForComp(editor,m3iBlk,~)
    if CanCreateModelForComp(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.createModelForComp(m3iBlk.handle);
    end
end


function result=CanLinkCompToModel(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        (autosar.composition.Utils.isComponentBlock(m3iBlk.handle)||...
        ((slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
        autosar.composition.Utils.isCompositionBlock(m3iBlk.handle)));
    end
end

function LinkCompToModel(editor,m3iBlk,~)
    if CanLinkCompToModel(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.linkCompToModel(m3iBlk.handle);
    end
end


function result=CanExportComponent(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty&&SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        autosar.composition.Utils.isComponentBlock(m3iBlk.handle)
        [isLinked,compMdlName]=autosar.composition.Utils.isCompBlockLinked(m3iBlk.handle);
        result=isLinked&&~isempty(compMdlName);
    end
end


function ExportComponent(editor,m3iBlk,~)
    if CanExportComponent(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.exportComponentBlock(m3iBlk.handle);
    end
end


function result=CanExportComposition(editor,m3iBlk)
    sel=editor.getSelection;
    result=~sel.isEmpty&&SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
    autosar.composition.Utils.isCompositionBlock(m3iBlk.handle);
end


function ExportComposition(editor,m3iBlk,~)
    if CanExportComposition(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.exportCompositionBlock(m3iBlk.handle);
    end
end


function result=CanSaveCompositionAsArchModel(editor,m3iBlk)
    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        autosar.composition.Utils.isCompBlockNonLinked(m3iBlk.handle)&&...
        ((slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
        autosar.composition.Utils.isCompositionBlock(m3iBlk.handle));
    end
end


function SaveCompositionAsArchModel(editor,m3iBlk,~)
    if CanSaveCompositionAsArchModel(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.createModelForComp(m3iBlk.handle);
    end
end


function result=CanImportComponentFromARXML(editor,m3iBlk)

    sel=editor.getSelection;
    result=false;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        autosar.composition.Utils.isCompBlockNonLinked(m3iBlk.handle)&&...
        autosar.composition.Utils.isComponentBlock(m3iBlk.handle)&&...
        ~autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(...
        bdroot(m3iBlk.handle));
    end
end

function ImportComponentFromARXML(editor,m3iBlk,~)
    if CanImportComponentFromARXML(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.importCompFromARXML(m3iBlk.handle);
    end
end


function result=CanImportCompositionFromARXML(editor,m3iBlk)
    result=false;
    if(slfeature('SaveAUTOSARCompositionAsArchModel')==0)


        return;
    end

    sel=editor.getSelection;
    if~sel.isEmpty
        result=SLStudio.Utils.objectIsValidBlock(m3iBlk)&&...
        autosar.composition.Utils.isCompositionBlock(m3iBlk.handle)&&...
        autosar.composition.Utils.isEmptyCompositionBlock(m3iBlk.handle)&&...
        autosar.composition.Utils.isCompBlockNonLinked(m3iBlk.handle);
    end
end

function ImportCompositionFromARXML(editor,m3iBlk,~)
    if CanImportCompositionFromARXML(editor,m3iBlk)
        autosar.composition.studio.CreateAndLink.importCompFromARXML(m3iBlk.handle);
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

function result=canShowCommentIcon(editor,element,~)
    result=false;
    if(slfeature('DesignReview_Comments')>0&&simulink.designreview.DesignReviewApp.getInstance().isCommentsAppOpen(bdroot(editor.getName)))
        if(isa(element,'SLM3I.Block')&&SLM3I.Util.isValidDiagramElement(element))
            result=true;
        end
    end
end

function ShowComment(editor,~,~)
    blk=simulink.designreview.Util.getSelectedBlock(editor);
    model=get_param(editor.getStudio.App.blockDiagramHandle,'Name');
    simulink.designreview.CommentsApi.addCommentForSingleSelect(model,blk);
end

function MARouteSegmentsOfBlock(editor,element,~)
    if MACanRouteSegmentsOfBlock(editor,element)
        SLM3I.SLDomain.routeSegmentsOfBlock(editor,element);
    end
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

function SSA_HighlightSignalToSrc(~,element,~)
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToSource(element.handle)
end

function SSA_HighlightSignalToDst(~,element,~)
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToDestination(element.handle)
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


