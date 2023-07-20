function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'EDASynthesis',pk.findclass('AbstractProp'));

    if isempty(findtype('SynthToolType')),
        schema.EnumType(...
        'SynthToolType',{'None','Vivado','ISE','Libero','Precision','Quartus','Synplify','Custom'});
    end
    schema.prop(c,'hdlsynthtool','SynthToolType');
    schema.prop(c,'hdlsynthcmd','string');
    schema.prop(c,'hdlsynthfilepostfix','string');
    schema.prop(c,'hdlsynthinit','string');
    schema.prop(c,'hdlsynthterm','string');



    p=schema.prop(c,'hdlsynthscript','bool');
    set(p,'FactoryValue',true);
    schema.prop(c,'hdlsynthlibcmd','string');
    schema.prop(c,'hdlsynthlibspec','string');


