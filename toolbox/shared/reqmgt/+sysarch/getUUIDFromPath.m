function identifier=getUUIDFromPath(iPath,modelName)

    identifier='';
    app=systemcomposer.internal.arch.load(modelName);
    if~isempty(app)
        zcModel=app.getArchViewsAppMgr.getZCModel;
        viewElem=zcModel.findElementWithPath(iPath);
        identifier=viewElem.getZCIdentifier;
    end
end

