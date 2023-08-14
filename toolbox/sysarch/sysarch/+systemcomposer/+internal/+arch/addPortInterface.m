function portInterface=addPortInterface(app,name)



    systemcomposer.internal.arch.internal.assertType(app,'Simulink.SystemArchitecture.internal.ApplicationManager');
    assert(ischar(name)||isstring(name),'Expect ''name'' argument to be a character array or a string');


    piCatalog=app.getTopLevelCompositionArchitecture.p_Model.getPortInterfaceCatalog();

    mdl=mf.zero.getModel(piCatalog);
    txn=mdl.beginTransaction;
    portInterface=piCatalog.addPortInterface(name);
    txn.commit;

end

