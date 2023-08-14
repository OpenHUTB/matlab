function schema






    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'SParametersPassiveNetwork');
    this=schema.class(rfPackage,'SParametersAmplifier',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    if isempty(findtype('NoiseDefinedByType'))
        schema.EnumType('NoiseDefinedByType',{...
        'Noise figure',...
        'Spot noise data',...
        'Noise factor',...
        'Noise temperature'});
    end

    schema.prop(this,'NoiseDefinedBy','NoiseDefinedByType');
    schema.prop(this,'NF','string');
    schema.prop(this,'GammaOpt','string');
    schema.prop(this,'FMIN','string');
    schema.prop(this,'RN','string');
    schema.prop(this,'NFactor','string');
    schema.prop(this,'NTemp','string');
    schema.prop(this,'NoiseDataFreq','string');






    if isempty(findtype('IP3Type'))
        schema.EnumType('IP3Type',{...
        'IIP3',...
        'OIP3'});
    end

    schema.prop(this,'IP3Type','IP3Type');
    schema.prop(this,'IIP3','string');
    schema.prop(this,'OIP3','string');
    schema.prop(this,'P1dB','string');
    schema.prop(this,'PSat','string');
    schema.prop(this,'GCSat','string');
    schema.prop(this,'NonlinearDataFreq','string');

