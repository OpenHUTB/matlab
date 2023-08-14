function piElem=addPortInterfaceElement(app,interface,name)



    systemcomposer.internal.arch.internal.assertType(app,'Simulink.SystemArchitecture.internal.ApplicationManager');
    assert(ischar(name)||isstring(name),'Expect ''name'' argument to be a character array or a string');


    mdl=app.getCompositionArchitectureModel;
    txn=mdl.beginTransaction;
    piElem=interface.addElement(name);
    txn.commit;

end

