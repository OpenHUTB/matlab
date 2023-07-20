function schema




    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');
    this=schema.class(package,'NCO',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('DSPNCOSourceEnum'))
        schema.EnumType('DSPNCOSourceEnum',{'Specify via dialog','Input port'});
    end
    if isempty(findtype('DSPNCOFormulaEnum'))
        schema.EnumType('DSPNCOFormulaEnum',{...
        'Sine','Cosine','Complex exponential','Sine and cosine'});
    end
    if isempty(findtype('DSPNCOCompMethodEnum'))
        schema.EnumType('DSPNCOCompMethodEnum',{...
        'Table lookup (no interpolation)'});
    end
    if isempty(findtype('DSPNCODataTypeEnum'))
        schema.EnumType('DSPNCODataTypeEnum',{...
        'double','single','Binary point scaling'});
    end


    schema.prop(this,'AccIncSrc','DSPNCOSourceEnum');
    schema.prop(this,'AccInc','ustring');
    schema.prop(this,'PhaseOffsetSrc','DSPNCOSourceEnum');
    schema.prop(this,'PhaseOffset','ustring');
    schema.prop(this,'AccumWL','ustring');
    schema.prop(this,'Formula','DSPNCOFormulaEnum');
    schema.prop(this,'HasPhaseQuantizer','bool');
    schema.prop(this,'HasOutputPhaseError','bool');
    schema.prop(this,'HasDither','bool');
    schema.prop(this,'DitherWL','ustring');
    schema.prop(this,'PNgeneratorLength','ustring');
    schema.prop(this,'SampleTime','ustring');
    schema.prop(this,'SamplesPerFrame','ustring');
    schema.prop(this,'DataType','DSPNCODataTypeEnum');
    schema.prop(this,'OutputWL','ustring');
    schema.prop(this,'OutputFL','ustring');
    schema.prop(this,'CompMethod','DSPNCOCompMethodEnum');
    schema.prop(this,'TableDepth','ustring');

