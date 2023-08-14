function schema







    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'NCO',parent);

    schema.prop(c,'Description','ustring');
    schema.prop(c,'PhaseIncrementSource','ustring');
    schema.prop(c,'PhaseIncrement','mxArray');
    schema.prop(c,'PhaseOffsetSource','ustring');
    schema.prop(c,'PhaseOffset','mxArray');
    schema.prop(c,'Dither','bool');
    schema.prop(c,'NumDitherBits','mxArray');
    schema.prop(c,'PhaseQuantization','bool');
    schema.prop(c,'NumQuantizerAccumulatorBits','mxArray');
    schema.prop(c,'PhaseQuantizationErrorOutputPort','bool');
    schema.prop(c,'Waveform','ustring');
    schema.prop(c,'SamplesPerFrame','mxArray');

    schema.prop(c,'RoundMode','ustring');
    schema.prop(c,'OverflowMode','ustring');

    schema.prop(c,'AccumulatorSLType','ustring');

    schema.prop(c,'OutputSLType','ustring');

    schema.prop(c,'PolyBitPattern','mxArray');
