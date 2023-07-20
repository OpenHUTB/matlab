function result=getRmiStruct(arg)



    result.domain='linktype_rmi_simulink';



    obj=sysarch.getLinkableObjectFromViewObject(arg);
    if isempty(obj)

        obj=arg;
    end

    if isa(obj,'systemcomposer.architecture.model.design.Port')
        impl=obj;
        impl=sysarch.getLinkableCompositionPort(impl);
        zcId=impl.getZCIdentifier;
    elseif isa(obj,'systemcomposer.arch.BasePort')
        impl=obj.getImpl;
        impl=sysarch.getLinkableCompositionPort(impl);
        zcId=impl.getZCIdentifier;
    elseif isa(obj,'systemcomposer.arch.BaseComponent')
        blkHdl=obj.SimulinkHandle;
        result=slreq.utils.getRmiStruct(blkHdl);
        return;
    elseif isa(obj,'autosar.arch.CompPort')
        blkHdl=obj.SimulinkHandle;
        result=slreq.utils.getRmiStruct(blkHdl);
        return;
    else
        if isa(obj,'mf.zero.ModelElement')
            zcId=obj.getZCIdentifier;
            impl=obj;
        else
            if isnumeric(obj)
                impl=systemcomposer.utils.getArchitecturePeer(obj(1));
                impl=sysarch.getLinkableCompositionPort(impl);
                zcId=impl.getZCIdentifier;
            else
                zcId=obj.ZCIdentifier;
                impl=obj.getImpl;
            end
        end
    end
    if(sysarch.isZCElement(zcId)||sysarch.isZCPort(zcId))
        result.id=zcId;
        modelId=systemcomposer.internal.arch.internal.getModelIdentifer(impl);
        result.artifact=which(modelId.URI);
    else
        error('Requirement linking is supported only for Components, Connectors and Ports');
    end

end
