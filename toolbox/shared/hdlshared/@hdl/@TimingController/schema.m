function schema



    mlock;


    package=findpackage('hdl');
    c=schema.class(package,'TimingController');
    p=schema.prop(c,'tcinfo','mxArray');
    set(p,'FactoryValue',struct());
end


