function schema








    mlock;


    package=findpackage('hdlfilter');

    c=schema.class(package,'TimingController');

    p=schema.prop(c,'tcinfo','mxArray');
    set(p,'FactoryValue',struct([]));
