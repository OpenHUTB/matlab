function testsort(model)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder)

    modelObj=get_param(model,'Object');

    delete(sess);
end
