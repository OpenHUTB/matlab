function schema

    pk=findpackage('dspfwiztargets');
    c=schema.class(pk,'realizemdltarget',pk.findclass('abstracttarget'));
    c.Description='Abstract';

    schema.prop(c,'OptimizeZeros','MATLAB array');
    schema.prop(c,'OptimizeOnes','MATLAB array');
    schema.prop(c,'OptimizeNegOnes','MATLAB array');
    schema.prop(c,'OptimizeDelayChains','MATLAB array');
    schema.prop(c,'MapCoeffsToPorts','on/off');
    schema.prop(c,'MapStates','on/off');
    schema.prop(c,'CoeffNames','mxArray');

    p=schema.prop(c,'gains','mxArray');
    p.Visible='off';

    p=schema.prop(c,'delays','mxArray');
    p.Visible='off';
    p=schema.prop(c,'privCoefficients','mxArray');
    p.AccessFlags.PublicSet='off';
    p.Visible='off';

    p=schema.prop(c,'privStates','mxArray');
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


