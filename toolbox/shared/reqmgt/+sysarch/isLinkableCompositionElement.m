function tf=isLinkableCompositionElement(elem)

    if isa(elem,'systemcomposer.architecture.model.design.Component')||...
        isa(elem,'systemcomposer.architecture.model.design.VariantComponent')||...
        isa(elem,'systemcomposer.architecture.model.design.Port')||...
        isa(elem,'systemcomposer.base.BaseComponent')||...
        isa(elem,'systemcomposer.base.BasePort')||...
        isa(elem,'systemcomposer.arch.ComponentPort')
        tf=true;
    else
        tf=false;
    end

    if(tf)

        if isa(elem,'mf.zero.ModelElement')
            mfModel=mf.zero.getModel(elem);
        else
            mfModel=mf.zero.getModel(elem.getImpl);
        end

        modelId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mfModel);
        if(modelId.modelType~=systemcomposer.services.proxy.ModelType.ARCH_COMP_MODEL&&...
            modelId.modelType~=systemcomposer.services.proxy.ModelType.ARCH_PROTECTED_COMP_MODEL)

            tf=false;
        end
    end

end