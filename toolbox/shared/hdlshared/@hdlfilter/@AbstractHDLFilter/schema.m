function schema






    mlock;

    shpkg=findpackage('hdlfilter');
    c=schema.class(shpkg,'AbstractHDLFilter');
    set(c,'Description','abstract');

    schema.prop(c,'FilterStructure','ustring');

    schema.prop(c,'Comment','mxArray');

    schema.prop(c,'FooterComment','mxArray');

    schema.prop(c,'CastBeforeSum','bool');

    schema.prop(c,'InputComplex','mxArray');

    p=schema.prop(c,'CodeGenMode','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'LocalTimingControllerInfo','mxArray');
    set(p,'FactoryValue',struct([]));



    p=schema.prop(c,'componentConnectivity','mxArray');
    set(p,'FactoryValue',struct('path','','inputs',{},'outputs',{}));










    findclass(findpackage('hdlcoderprops'),'HDLProps');
    p=schema.prop(c,'HDLParameters','hdlcoderprops.HDLProps');%#ok



    p=schema.prop(c,'numChannel','mxArray');
    set(p,'FactoryValue',1);


    schema.prop(c,'coeffPort','bool');
