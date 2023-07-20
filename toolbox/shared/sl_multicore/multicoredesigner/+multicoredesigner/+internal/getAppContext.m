function context=getAppContext(modelH)
    context=[];

    if slfeature('SLMulticore')>0
        das=DAS.Studio.getAllStudios();

        studioApp=[];
        for i=1:length(das)
            da=das{i};
            sa=da.App;
            if sa.blockDiagramHandle==modelH
                studioApp=sa;
                break;
            end
        end
        if isempty(studioApp)
            return;
        end

        acm=studioApp.getAppContextManager;
        context=acm.getCustomContext('multicoreDesignerApp');
    else
        context=multicoredesigner.internal.MulticoreContextManager.getContext(modelH);
    end
end