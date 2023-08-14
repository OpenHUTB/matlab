function zcElement=resolveZCElement(identifierStr,modelName)






    zcElement=mf.zero.ModelElement.empty;
    if isempty(modelName)||~Simulink.internal.isArchitectureModel(modelName)
        return;
    end

    app=systemcomposer.internal.arch.load(modelName);
    compMFModel=app.getCompositionArchitectureModel;
    viewMFModel=app.getArchViewsAppMgr.getModel;

    if~isempty(app)
        model=app.getArchViewsAppMgr.getModel;
        parts=strsplit(identifierStr,':');
        if strcmp(parts{1},'ZC')&&~isempty(model)
            uuid=parts{2};
            zcElement=viewMFModel.findElement(uuid);
            if isempty(zcElement)
                zcElement=compMFModel.findElement(uuid);
            end
        end
    end
end

