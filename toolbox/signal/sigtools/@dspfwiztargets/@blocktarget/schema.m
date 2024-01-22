function schema

    pk=findpackage('dspfwiztargets');
    c=schema.class(pk,'blocktarget',pk.findclass('abstracttarget'));
    c.Description='Abstract';

    schema.prop(c,'MapStates','on/off');

    schema.prop(c,'Link2Obj','on/off');

    schema.prop(c,'MapCoeffsToPorts','on/off');
    schema.prop(c,'CoeffNames','mxArray');
    p=schema.prop(c,'BlockHandle','mxArray');
    p.Visible='off';

    schema.prop(c,'CoeffNames','mxArray');
    p=schema.prop(c,'privCoefficients','mxArray');
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


