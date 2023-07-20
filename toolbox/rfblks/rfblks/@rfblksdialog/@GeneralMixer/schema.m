function schema






    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'GeneralAmplifier');
    this=schema.class(rfPackage,'GeneralMixer',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    if isempty(findtype('MixerType'))
        schema.EnumType('MixerType',{...
        'Downconverter',...
        'Upconverter'});
    end

    schema.prop(this,'MixerType','MixerType');
    schema.prop(this,'FLO','string');






    schema.prop(this,'FreqOffset','string');
    schema.prop(this,'PhaseNoiseLevel','string');


