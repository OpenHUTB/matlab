function report=getAnalyzerReport(this)





    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=dataLayer.getWorkflowTopologyFacade(this.TopModel);



    report=facade.query(this.TopModel,'type','Prepare','property','Results','limit',1);
    report=report{1};
end