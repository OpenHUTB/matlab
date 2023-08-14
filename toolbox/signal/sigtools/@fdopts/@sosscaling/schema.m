function schema





    pk=findpackage('fdopts');
    c=schema.class(pk,'sosscaling');

    if isempty(findtype('sosReorderOpts'))
        schema.EnumType('sosReorderOpts',{'auto','none','up','down','lowpass','highpass','bandpass','bandstop'});
    end
    p=schema.prop(c,'sosReorder','sosReorderOpts');%#ok<NASGU>

    p=schema.prop(c,'MaxNumerator','posdouble');
    p.FactoryValue=2;

    if isempty(findtype('numeratorConstraintOpts'))
        schema.EnumType('numeratorConstraintOpts',{'none','unit','normalize','po2'});
    end
    p=schema.prop(c,'NumeratorConstraint','numeratorConstraintOpts');%#ok<NASGU>

    if isempty(findtype('scalingOverflowMode'))
        schema.EnumType('scalingOverflowMode',{'wrap','saturate','satall'});
    end
    p=schema.prop(c,'OverflowMode','scalingOverflowMode');%#ok<NASGU>

    if isempty(findtype('scaleValueConstraintOpts'))
        schema.EnumType('scaleValueConstraintOpts',{'unit','none','po2'});
    end
    p=schema.prop(c,'ScaleValueConstraint','scaleValueConstraintOpts');%#ok<NASGU>



    p=schema.prop(c,'MaxScaleValue','mxArray');
    p.SetFunction=@set_svmax;
    p.GetFunction=@get_svmax;
    p.AccessFlags.Init='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';

    p=schema.prop(c,'privsvmax','posdouble');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.FactoryValue=1;


