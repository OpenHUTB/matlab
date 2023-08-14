



function switchView(isReqView,context)

    if isReqView
        contextName='ReqsView';
    else
        contextName='LinksView';
    end

    LOCALCONTEXT='requirementsEditorAppContext_';



    context.TypeChain={[LOCALCONTEXT,contextName],'disableTraceDiagramButton'};



    if isa(context,'slreq.toolstrip.ReqEditorAppContext')




        context.isReqSetSelected=false;
    end
end