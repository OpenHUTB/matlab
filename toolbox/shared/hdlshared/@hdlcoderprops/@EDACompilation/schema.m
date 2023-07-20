function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'EDACompilation',pk.findclass('AbstractProp'));

    schema.prop(c,'compile_cmd','string');

    schema.prop(c,'hdlcompilefilepostfix','string');
    schema.prop(c,'hdlcompileinit','string');
    schema.prop(c,'hdlcompileterm','string');
    schema.prop(c,'hdlcompileverilogcmd','string');
    schema.prop(c,'hdlcompilevhdlcmd','string');


    p=schema.prop(c,'hdlcompilescript','bool');
    set(p,'FactoryValue',true);



    p=schema.prop(c,'hdlelaborationcmd','ustring');
    set(p,'Visible','Off','FactoryValue','');

    p=schema.prop(c,'hdlcodecoveragecompilationflag','ustring');
    set(p,'Visible','Off','FactoryValue','');

    p=schema.prop(c,'hdlcodecoverageelaborationFlag','ustring');
    set(p,'Visible','Off','FactoryValue','');



    schema.prop(c,'hdlcompiletb','bool');


