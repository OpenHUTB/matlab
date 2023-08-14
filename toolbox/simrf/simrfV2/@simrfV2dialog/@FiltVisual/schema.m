function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'FiltVisual',parent);


    m=schema.method(this,'simrfV2filtvisualplot');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};







    if isempty(findtype('SimRFV2EnumsDefineFitVisual'))
        schema.EnumType('SimRFV2EnumsDefineFitVisual',{'Yes'});

        schema.EnumType('SimRFV2FiltPlotLeft',{...
        'Voltage transfer','Phase delay','Group delay'});


        schema.EnumType('SimRFV2FiltPlotRightOnVT',{...
        'None','Voltage transfer','Phase delay','Group delay'});

        schema.EnumType('SimRFV2FiltPlotRightNoTD',{...
        'None','Voltage transfer','Group delay'});

        schema.EnumType('SimRFV2FiltPlotRightNoGD',{...
        'None','Voltage transfer','Phase delay'});

        schema.EnumType('SimRFV2FiltPlotRightNoIR',{...
        'None','Step response'});

        schema.EnumType('SimRFV2FiltPlotRightNoSR',{...
        'None','Impulse response'});

        schema.EnumType('SimRFV2FiltAxesOptionType',{...
        'Linear','Logarithmic'});

        schema.EnumType('SimRFV2FiltPlotFormatType',{...
        'Magnitude (dB)','Magnitude (linear)',...
        'Angle (degrees)','Real','Imaginary'});
    end

    schema.prop(this,'PlotFuncLeft','SimRFV2FiltPlotLeft');
    schema.prop(this,'PlotLeftForm','SimRFV2FiltPlotFormatType');
    schema.prop(this,'PlotRightOnVT','SimRFV2FiltPlotRightOnVT');
    schema.prop(this,'PlotRightNoTD','SimRFV2FiltPlotRightNoTD');
    schema.prop(this,'PlotRightNoGD','SimRFV2FiltPlotRightNoGD');
    schema.prop(this,'PlotRightNoIR','SimRFV2FiltPlotRightNoIR');
    schema.prop(this,'PlotRightNoSR','SimRFV2FiltPlotRightNoSR');
    schema.prop(this,'PlotRightForm','SimRFV2FiltPlotFormatType');
    schema.prop(this,'FreqPoints','string');
    schema.prop(this,'Freq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'TimePoints','string');
    schema.prop(this,'Time_unit','SimRFV2TimeUnitType');
    schema.prop(this,'XaxisScale','SimRFV2FiltAxesOptionType');
    schema.prop(this,'YaxisScale','SimRFV2FiltAxesOptionType');

