function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'EDAMapping',pk.findclass('AbstractProp'));

    schema.prop(c,'hdlmapfilepostfix','string');
    schema.prop(c,'hdlmapseparator','string');

    p=schema.prop(c,'hdlmapfile','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'hdlmaparrow','string');
    set(p,'FactoryValue','-->');


