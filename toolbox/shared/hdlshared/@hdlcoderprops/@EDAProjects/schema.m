function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'EDAProjects',pk.findclass('AbstractProp'));

    schema.prop(c,'hdlsimprojectcmd','string');
    schema.prop(c,'hdlsimprojectterm','string');
    schema.prop(c,'hdlsimprojectfilepostfix','string');
    schema.prop(c,'hdlsimprojectinit','string');



    p=schema.prop(c,'hdlsimprojectscript','bool');
    set(p,'FactoryValue',true);


