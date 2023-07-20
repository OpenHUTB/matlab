function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'EDASimulation',pk.findclass('AbstractProp'));

    schema.prop(c,'hdlsimcmd','string');
    schema.prop(c,'hdlsimfilepostfix','string');
    schema.prop(c,'hdlsiminit','string');
    schema.prop(c,'hdlsimterm','string');
    schema.prop(c,'hdlsimviewwavecmd','string');



    p=schema.prop(c,'hdlsimscript','bool');
    set(p,'FactoryValue',true);



    p=schema.prop(c,'hdlcodecoveragesimulationflag','ustring');
    set(p,'Visible','Off','FactoryValue','');

    p=schema.prop(c,'hdlcodecoveragereportgen','ustring');
    set(p,'Visible','Off','FactoryValue','');

    p=schema.prop(c,'hdlsimviewwavesetupcmd','ustring');
    set(p,'Visible','Off','FactoryValue','');






