function ThreePhaseTapChangingTransformerCback(block)


    Parameters=Simulink.Mask.get(block).Parameters;
    SaturationCurrentFlux=strcmp(get_param(block,'MaskNames'),'SaturationCurrentFlux')==1;
    Lmag=strcmp(get_param(block,'MaskNames'),'Lmag')==1;
    L0=strcmp(get_param(block,'MaskNames'),'L0')==1;
    ReferenceVoltage=strcmp(get_param(block,'MaskNames'),'ReferenceVoltage')==1;
    DeadBand=strcmp(get_param(block,'MaskNames'),'DeadBand')==1;
    Delay=strcmp(get_param(block,'MaskNames'),'Delay')==1;
    SpecifyInitialFluxes=strcmp(get_param(block,'MaskNames'),'SpecifyInitialFluxes')==1;
    InitialFluxes=strcmp(get_param(block,'MaskNames'),'InitialFluxes')==1;
    Threshold=strcmp(get_param(block,'MaskNames'),'Threshold')==1;
    switch get_param(block,'CoreType')
    case 'Three single-phase transformers'
        Parameters(L0).Visible='off';
    otherwise
        Parameters(L0).Visible='on';
    end
    switch get_param(block,'SetSaturation')
    case 'on'
        Parameters(Lmag).Visible='off';
        Parameters(SaturationCurrentFlux).Visible='on';
        Parameters(SpecifyInitialFluxes).Visible='on';
        Parameters(InitialFluxes).Visible=get_param(block,'SpecifyInitialFluxes');
    case 'off'
        Parameters(Lmag).Visible='on';
        Parameters(SaturationCurrentFlux).Visible='off';
        Parameters(SpecifyInitialFluxes).Visible='off';
        Parameters(InitialFluxes).Visible='off';
    end
    switch get_param(block,'ControlMode')
    case 'Tap control'
        Parameters(Threshold).Visible='on';
        Parameters(ReferenceVoltage).Visible='off';
        Parameters(DeadBand).Visible='off';
        Parameters(Delay).Visible='off';
    case 'Voltage regulation'
        Parameters(Threshold).Visible='off';
        Parameters(ReferenceVoltage).Visible='on';
        Parameters(DeadBand).Visible='on';
        Parameters(Delay).Visible='on';
    end
    if~isequal(get_param([block,'/Control Type'],'LabelModeActiveChoice'),get_param(block,'ControlMode'))
        set_param([block,'/Control Type'],'LabelModeActiveChoice',get_param(block,'ControlMode'));
    end