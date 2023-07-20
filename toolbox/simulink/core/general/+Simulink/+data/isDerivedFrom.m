function isSubclass=isDerivedFrom(hClass,superclassName)





    superclassName=convertStringsToChars(superclassName);

    assert(isscalar(hClass));
    assert(isa(hClass,'meta.class'));
    if strcmp(superclassName,'Simulink.Data')
        isSubclass=((hClass<=?Simulink.Parameter)||...
        (hClass<=?Simulink.Signal));
    else
        superclass=meta.class.fromName(superclassName);
        assert(~isempty(superclass),'Superclass does not exist');
        isSubclass=hClass<=superclass;
    end


