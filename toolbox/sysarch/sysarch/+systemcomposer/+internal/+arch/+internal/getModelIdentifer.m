function modelId=getModelIdentifer(elem)




    mfModel=mf.zero.getModel(elem);
    if(isempty(mfModel))
        error('Input element must be a ModelElement');
    end

    modelId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mfModel);
end

