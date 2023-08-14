function applyDataTypes(this,runName)















    this.assertDEValid();

    this.loadSystems();

    p=inputParser;
    p.addRequired('runName',@(x)this.validateRunName(x));
    try
        p.parse(runName);
    catch

        error(message('SimulinkFixedPoint:autoscaling:msgNoProposedFL'));
    end

    results=this.results(runName);

    noResultsToApply=false;
    if isempty(results)
        noResultsToApply=true;
    else
        resultProposedDTs={results.ProposedDataType};
        if all(strcmp('',resultProposedDTs)|strcmp('n/a',resultProposedDTs))
            noResultsToApply=true;
        end
    end
    if noResultsToApply
        error(message('SimulinkFixedPoint:autoscaling:msgNoProposedFL'));
    end


    this.performApplyDataTypes(runName);


    dataLayer=fxptds.DataLayerInterface.getInstance();
    [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,runName);
    context=fxptds.WorkflowTopology.WorkflowContextFactory.getContext(fxptds.UserIntent.AutoscalerApply,...
    'TopModel',this.TopModel,'FPTRunID',fptRunID);
    facade=this.getWorkflowTopologyFacade();
    facade.register(context);

end
