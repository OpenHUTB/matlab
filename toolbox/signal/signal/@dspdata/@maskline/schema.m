function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'maskline');

    p=schema.prop(c,'EnableMask','bool');

    p=schema.prop(c,'NormalizedFrequency','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'FrequencyVector','double_vector');
    set(p,'FactoryValue',[0,.4,.5,1]);

    if isempty(findtype('MagnitudeUnitTypes'))
        schema.EnumType('MagnitudeUnitTypes',{'dB','Linear','Squared'});
    end

    schema.prop(c,'MagnitudeUnits','MagnitudeUnitTypes');

    p=schema.prop(c,'MagnitudeVector','mxArray');
    set(p,'SetFunction',@set_magnitudevector,...
    'GetFunction',@get_magnitudevector,...
    'AccessFlags.Init','Off');


    p=schema.prop(c,'privMagnitudeVector','double_vector');
    set(p,'AccessFlags.PublicSet','Off',...
    'AccessFlags.PublicGet','Off',...
    'FactoryValue',[1,1,.01,.01]);


