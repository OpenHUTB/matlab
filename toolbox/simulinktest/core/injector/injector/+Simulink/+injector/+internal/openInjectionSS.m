function openInjectionSS(designMdlH,injRefH,injMdlName,injSS)

    mdlName=get_param(designMdlH,'Name');
    if~exist(injMdlName,'file')
        Simulink.injector.internal.error({'Simulink:Injector:InjMdlNotFound',injMdlName,getfullname(injRefH)},true,'Simulink:Injector:InjectorStage',mdlName);
        return;
    end

    if~bdIsLoaded(injMdlName)
        try
            injMdlH=load_system(injMdlName);
            Simulink.sltblkmap.internal.convertStandaloneMdlToContexted(injMdlH,injRefH);
        catch ME
            Simulink.injector.internal.error(ME,true,'Simulink:Injector:InjectorStage',mdlName);
            return
        end
    else
        injMdlH=get_param(injMdlName,'handle');
        ctxBlk=get_param(injMdlH,'CoSimContext');
        if isempty(ctxBlk)||get_param(ctxBlk,'Handle')~=injRefH
            try
                Simulink.sltblkmap.internal.convertStandaloneMdlToContexted(injMdlH,injRefH);
            catch ME
                Simulink.injector.internal.error(ME,true,'Simulink:Injector:InjectorStage',mdlName);
                return
            end
        end
    end

    blkH=get_param(injSS,'handle');
    sys=get_param(blkH,'Parent');
    if~strcmp(get_param(sys,'Open'),'on')
        open_system(sys,'force','Window');
    else
        open_system(sys);
    end

    mdlH=bdroot(blkH);
    SLStudio.HighlightSignal.removeHighlighting(mdlH);
    SLStudio.EmphasisStyleSheet.applyStyler(mdlH,blkH);

    safety.gui.dialog.Callbacks.refreshPropInspFaultModel(blkH);

end
