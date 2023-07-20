function schema






    package=findpackage('dspfixptddg');
    parent=findclass(package,'DSPDDGBase');
    this=schema.class(package,'Window',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('DSPWindowModeEnum'))
        schema.EnumType('DSPWindowModeEnum',{...
        'Apply window to input',...
        'Generate window',...
        'Generate and apply window'});
    end
    if isempty(findtype('DSPWindowTypeEnum'))
        schema.EnumType('DSPWindowTypeEnum',{...
        'Bartlett',...
        'Blackman',...
        'Boxcar',...
        'Chebyshev',...
        'Hamming',...
        'Hann',...
        'Hanning',...
        'Kaiser',...
        'Taylor',...
        'Triang',...
        'User defined'});
    end
    if isempty(findtype('DSPWindowSamplingModeEnum'))
        schema.EnumType('DSPWindowSamplingModeEnum',{...
        'Symmetric',...
        'Periodic'});
    end

    if isempty(findtype('DSPWindowSourceDataTypeEnum'))
        schema.EnumType('DSPWindowSourceDataTypeEnum',{...
        'double',...
        'single',...
        'Fixed-point',...
        'User-defined',...
        'Inherit via back propagation'});
    end


    schema.prop(this,'winmode','DSPWindowModeEnum');
    schema.prop(this,'wintype','DSPWindowTypeEnum');
    schema.prop(this,'sampmode','DSPSampleModeEnum');
    schema.prop(this,'samptime','ustring');
    schema.prop(this,'N','ustring');
    schema.prop(this,'Rs','ustring');
    schema.prop(this,'beta','ustring');
    schema.prop(this,'numSidelobes','ustring');
    schema.prop(this,'sidelobeLevel','ustring');
    schema.prop(this,'winsamp','DSPWindowSamplingModeEnum');
    schema.prop(this,'UserWindow','ustring');
    schema.prop(this,'OptParams','bool');
    schema.prop(this,'UserParams','ustring');


    schema.prop(this,'dataType','DSPWindowSourceDataTypeEnum');
    schema.prop(this,'isSigned','bool');
    schema.prop(this,'wordLen','ustring');
    schema.prop(this,'udDataType','ustring');
    schema.prop(this,'fracBitsMode','DSPSourceFracBitsModeEnum');
    schema.prop(this,'numFracBits','ustring');
