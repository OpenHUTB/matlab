function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'Visual',parent);


    m=schema.method(this,'simrfV2visualplot');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};







    if isempty(findtype('SimRFV2EnumsDefineVisual'))
        schema.EnumType('SimRFV2EnumsDefineVisual',{'Yes'});

        schema.EnumType('SimRFV2SourceFreqType',{...
        'User-specified','Extracted from data source'});

        schema.EnumType('SimRFV2AllPlotType',{...
        'X-Y plane','Polar plane','Z Smith chart',...
        'Y Smith chart','ZY Smith chart'});

        schema.EnumType('SimRFV2AxesOptionType',{...
        'Linear','Logarithmic'});

        schema.EnumType('SimRFV2PlotFormatType',{...
        'Magnitude (dB)','Magnitude (linear)',...
        'Angle (degrees)','Real','Imaginary'});
    end

    schema.prop(this,'SourceFreq','SimRFV2SourceFreqType');
    schema.prop(this,'PlotFreq','string');
    schema.prop(this,'PlotFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'PlotType','SimRFV2AllPlotType');
    schema.prop(this,'YParam1','string');
    schema.prop(this,'YParam2','string');
    schema.prop(this,'YFormat1','SimRFV2PlotFormatType');
    schema.prop(this,'YFormat2','SimRFV2PlotFormatType');
    schema.prop(this,'YOption','SimRFV2AxesOptionType');
    schema.prop(this,'XOption','SimRFV2AxesOptionType');

