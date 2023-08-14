function refresh(obj)









    if~isempty(slCustomizer.RecursionGuard)
        return;
    end


    xtester_emulate_ctrl_c('slCustomizer_refresh');



    if slprivate('disableRunCustomization')
        disp('Skipping all customization.');
        return;
    end

    slCustomizer.RecursionGuard(1);
    c=onCleanup(@()clearRecursionGuard());
    load_simulink;

    hasConfig=~isempty(which('simulink.toolstrip.internal.resetConfig'));
    if hasConfig

        simulink.toolstrip.internal.resetConfig();
    end





    ex=[];
    try



        PerfTools.Tracer.logSLStartupData('slCustomizer.refresh',true);

        currentDir=pwd;
        cm=obj.CustomizationManager;

        cm.clearCustomizers;
        cm.clearDlgPreOpenFcns;
        cm.clearCustomMenuFcns;
        cm.clearCustomFilterFcns;
        cm.clearModelAdvisorCheckFcns;
        cm.clearModelAdvisorTaskFcns;
        cm.clearModelAdvisorProcessFcns;
        cm.clearModelAdvisorTaskAdvisorFcns;
        cm.clearSigScopeMgrViewerLibraries;
        cm.clearSigScopeMgrGeneratorLibraries;


        daSvc=DAServiceManager.OnDemandService;
        daSvc.Initialize();


        if isfield(struct(cm),'ObjectiveCustomizer')
            cm.ObjectiveCustomizer.clear;
        end

        if~isempty(which('ModelAdvisor.Root'))
            mp=ModelAdvisor.Preferences;
            if~mp.EnableCustomizationCache

                maroot=ModelAdvisor.Root;
                maroot.clear;
            end
        end

        if~cm.isEnabled
            disp('Customizations not refreshed because the CustomizationManager has been disabled.');
            return;
        end



        if exist('Simulink.scopes.ViewerLibraryCache','class')
            vlcache=Simulink.scopes.ViewerLibraryCache.Instance;
            vlcache.reset();
        else
            vlcache=[];
        end



        try

            callAllMethods(obj,'internalCustomization');


            callAll(obj,'sl_internal_customization');
            cd(currentDir);


            callAllMethods(obj,'customization');


            callAll(obj,'sl_customization');
            cd(currentDir);
        catch me
            warning(me.identifier,'%s',me.message);
        end




        if~isempty(vlcache)
            vlcache.loadCustomLibraries(cm);
        end
    catch me
        m=message('Simulink:utility:CustomizationError');
        ex=MException(m.Identifier,m.getString());
        ex=ex.addCause(me);
    end


    daSvc.CustomizerRefresh();

    cd(currentDir);
    cm.updateEditors;
    PerfTools.Tracer.logSLStartupData('slCustomizer.refresh',false);

    if~isempty(ex)
        throw(ex);
    end

    function clearRecursionGuard()
        out=slCustomizer.RecursionGuard([]);
    end
end




