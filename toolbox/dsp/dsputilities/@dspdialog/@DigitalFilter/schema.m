function schema






    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');
    fixptPackage=findpackage('dspfixptddg');
    findclass(fixptPackage,'FixptDialog');

    this=schema.class(package,'DigitalFilter',parent);


    schema.prop(this,'MaskFixptDialog','dspfixptddg.FixptDialog');


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('DSPDigitalFilterTransferFunction'))
        schema.EnumType('DSPDigitalFilterTransferFunction',...
        {'IIR (poles & zeros)',...
        'IIR (all poles)',...
        'FIR (all zeros)'});
    end

    if isempty(findtype('DSPDigitalFilterDialogModeIIRStructure'))
        schema.EnumType('DSPDigitalFilterDialogModeIIRStructure',...
        {'Direct form I',...
        'Direct form I transposed',...
        'Direct form II',...
        'Direct form II transposed',...
        'Biquad direct form I (SOS)',...
        'Biquad direct form I transposed (SOS)',...
        'Biquad direct form II (SOS)',...
        'Biquad direct form II transposed (SOS)'});
    end

    if isempty(findtype('DSPDigitalFilterPortsModeIIRStructure'))
        schema.EnumType('DSPDigitalFilterPortsModeIIRStructure',...
        {'Direct form I',...
        'Direct form I transposed',...
        'Direct form II',...
        'Direct form II transposed'});
    end

    if isempty(findtype('DSPDigitalFilterIIRAllPoleStructure'))
        schema.EnumType('DSPDigitalFilterIIRAllPoleStructure',...
        {'Direct form',...
        'Direct form transposed',...
        'Lattice AR'});
    end

    if isempty(findtype('DSPDigitalFilterFIRStructure'))
        schema.EnumType('DSPDigitalFilterFIRStructure',...
        {'Direct form',...
        'Direct form symmetric',...
        'Direct form antisymmetric',...
        'Direct form transposed',...
        'Lattice MA'});
    end

    if isempty(findtype('DSPDigitalFilterCoeffSource'))
        schema.EnumType('DSPDigitalFilterCoeffSource',...
        {'Specify via dialog',...
        'Input port(s)'});
    end

    if isempty(findtype('DSPDigitalFilterFiltPerSampPopup'))
        schema.EnumType('DSPDigitalFilterFiltPerSampPopup',...
        {'One filter per frame',...
        'One filter per sample'});
    end


    schema.prop(this,'FilterSource','int');
    schema.prop(this,'dfiltObjectName','ustring');
    schema.prop(this,'DialogModeTransferFunction','DSPDigitalFilterTransferFunction');
    schema.prop(this,'PortsModeTransferFunction','DSPDigitalFilterTransferFunction');
    schema.prop(this,'DialogModeIIRStructure','DSPDigitalFilterDialogModeIIRStructure');
    schema.prop(this,'DialogModeIIRAllPoleStructure','DSPDigitalFilterIIRAllPoleStructure');
    schema.prop(this,'DialogModeFIRStructure','DSPDigitalFilterFIRStructure');
    schema.prop(this,'PortsModeIIRStructure','DSPDigitalFilterPortsModeIIRStructure');
    schema.prop(this,'PortsModeIIRAllPoleStructure','DSPDigitalFilterIIRAllPoleStructure');
    schema.prop(this,'PortsModeFIRStructure','DSPDigitalFilterFIRStructure');
    schema.prop(this,'CoeffSource','DSPDigitalFilterCoeffSource');
    schema.prop(this,'NumCoeffs','ustring');
    schema.prop(this,'DenCoeffs','ustring');
    schema.prop(this,'RefCoeffs','ustring');
    schema.prop(this,'SOSCoeffs','ustring');
    schema.prop(this,'ScaleValues','ustring');
    schema.prop(this,'denIgnore','bool');
    schema.prop(this,'FiltPerSampPopup','DSPDigitalFilterFiltPerSampPopup');
    schema.prop(this,'ICs','ustring');
    schema.prop(this,'ZeroSideICs','ustring');
    schema.prop(this,'PoleSideICs','ustring');
    schema.prop(this,'InputProcessing','DSPUpgradedInputProcessingEnum');
