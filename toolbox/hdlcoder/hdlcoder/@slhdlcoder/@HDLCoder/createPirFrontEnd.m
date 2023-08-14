function[p,slFrontend]=createPirFrontEnd(this,slConnection,treatAsReferencedModel)





    mdlName=slConnection.ModelName;
    p=this.createPirObject(mdlName);


    slFrontend=slhdlcoder.SimulinkFrontEnd(this,slConnection,p,treatAsReferencedModel);


    this.FrontEnd=slFrontend;
    configManager=this.getConfigManager(mdlName);

    slFrontend.setupAndInitModel(configManager);

end
