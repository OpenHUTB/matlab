function autosar_ui_launch(modelH)















    modelH=get_param(modelH,'handle');


    cs=getActiveConfigSet(modelH);
    if isempty(cs)
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    end
    if strcmp(get_param(cs,'AutosarCompliant'),'off')
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end


    if autosar.api.Utils.isMappedToComposition(modelH)&&...
        ~Simulink.internal.isArchitectureModel(modelH,'AUTOSARArchitecture')
        DAStudio.error('autosarstandard:ui:uiCompositionNotSupported',getfullname(modelH));
    end

    [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(modelH);
    if isMappedToSubComponent
        DAStudio.error('autosarstandard:ui:subComponentNotSupported');
    end

    solverType=get_param(modelH,'SolverType');
    if~strcmp(solverType,'Fixed-step')
        DAStudio.error('RTW:autosar:fixedStepSolverAUTOSAR');
    end


    arExplorer=autosar.ui.utils.findExplorerForModel(modelH);
    if~isempty(arExplorer)
        arExplorer.show();
        return;
    end


    pb=Simulink.internal.ScopedProgressBar(...
    DAStudio.message('RTW:autosar:launchUIProgressBar'));
    c=onCleanup(@()delete(pb));

    [isMapped,mapping]=autosar.api.Utils.isMapped(modelH);
    if~isMapped

        [islicensed,errorargs]=autosar.api.Utils.autosarlicensed();
        if~islicensed
            DAStudio.error(errorargs{:});
        end

        try

            cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

            autosar.ui.app.quickstart.WizardManager.wizard(modelH);
        catch Me

            autosar.mm.util.MessageReporter.throwException(Me);
        end
    else
        try

            cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

            arRoot=autosar.api.Utils.m3iModel(modelH,IsUIMode=true);
        catch Me

            autosar.mm.util.MessageReporter.throwException(Me);
        end
        if isempty(arRoot)
            assert(false,'Empty Autosar root');
        elseif isempty(mapping.MappedTo)
            assert(false,'Empty MappedTo component');
        end

        viewWidget=autosar.ui.launch(modelH);
        sys=get_param(modelH,'object');
        LocalCheckCloseListener(sys,viewWidget,@LocalCloseForExplorerCB);
        LocalCheckStfChangedListener(modelH,viewWidget,@LocalStfChangedCB);
    end

end



function LocalCheckCloseListener(theSys,uddUI,cbFunc)
    listnerObj=Simulink.listener(theSys,'CloseEvent',cbFunc);
    uddUI.closeListener=listnerObj;
end



function LocalCloseForExplorerCB(eventSrc,~)
    autosar_ui_close(eventSrc.Name);
end



function LocalCheckStfChangedListener(modelH,uddUI,cbFunc)
    mmgr=get_param(modelH,'MappingManager');
    uddUI.stfChangedListener=event.listener(mmgr,'ChangeMappingView',cbFunc);
end



function LocalStfChangedCB(mmgr,~)
    mappingType=mmgr.getCurrentMapping();
    arMapping=getActiveAUTOSARMapping(mmgr);
    modelName=autosar.api.Utils.getModelNameFromMapping(arMapping);
    if~any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP'}))

        autosar_ui_close(modelName);
    else



        m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
        if(isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')&&...
            strcmp(mappingType,'AutosarTarget'))||...
            (~isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')&&...
            strcmp(mappingType,'AutosarTargetCPP'))



            autosar_ui_close(modelName);
        end
    end
end



function mapping=getActiveAUTOSARMapping(mmgr)
    mapping=mmgr.getActiveMappingFor('AutosarTarget');
    if isempty(mapping)
        mapping=mmgr.getActiveMappingFor('AutosarTargetCPP');
    end
end



