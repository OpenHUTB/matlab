function out=getRequiredInterfaceSupportFlags(model)
    modelInterface=get_param(model,'Object');
    assert(isa(modelInterface,'Simulink.BlockDiagram'));

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
    oc=onCleanup(@()Simulink.CMI.EIAdapter(sess.oldFeatureValue));

    out=modelInterface.getRequiredInterfaceSupportFlags;
end
