function initializeDict(dd,loadSLPkg,reset)




    import coder.internal.CoderDataStaticAPI.*;


    hlp=getHelper();
    if reset
        hlp.deleteAll(dd);
    end


    hlp.setProp(dd.owner,'Status','Initializing');
    oc=onCleanup(@()hlp.setProp(dd.owner,'Status','Ready'));

    hlp.createSWCT(dd);


    if slfeature('HideBuiltinStorageClasses')==0
        dd.owner.addReferencedContainer('SimulinkBuiltin');
    end
    if loadSLPkg
        dd.owner.addReferencedContainer('Simulink');
    end

end
