function ThreePhaseAutotransformerWithTertiaryWindingCback(block)


    Parameters=Simulink.Mask.get(block).Parameters;
    Lm=strcmp(get_param(block,'MaskNames'),'Lm')==1;
    L0=strcmp(get_param(block,'MaskNames'),'L0')==1;
    Saturation=strcmp(get_param(block,'MaskNames'),'Saturation')==1;
    SpecifyInitialFluxes=strcmp(get_param(block,'MaskNames'),'SpecifyInitialFluxes')==1;
    InitialFluxes=strcmp(get_param(block,'MaskNames'),'InitialFluxes')==1;
    DiscreteSolver=strcmp(get_param(block,'MaskNames'),'DiscreteSolver')==1;
    switch get_param(block,'CoreType')
    case 'Three single-phase transformers'
        Parameters(L0).Visible='off';
    otherwise
        Parameters(L0).Visible='on';
    end
    switch get_param(block,'SetSaturation')
    case 'on'
        Parameters(Lm).Visible='off';
        Parameters(Saturation).Visible='on';
        Parameters(SpecifyInitialFluxes).Visible='on';
        Parameters(InitialFluxes).Visible=get_param(block,'SpecifyInitialFluxes');
    case 'off'
        Parameters(Lm).Visible='on';
        Parameters(Saturation).Visible='off';
        Parameters(SpecifyInitialFluxes).Visible='off';
        Parameters(InitialFluxes).Visible='off';
    end
    switch get_param(block,'BreakLoop')
    case 'on'
        Parameters(DiscreteSolver).Visible='off';
    case 'off'
        Parameters(DiscreteSolver).Visible='on';
    end
    aMaskObj=Simulink.Mask.get(block);
    AdvancedTab=aMaskObj.getDialogControl('Advanced');
    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        AdvancedTab.Visible='off';
    else
        if PowerguiInfo.AutomaticDiscreteSolvers
            AdvancedTab.Visible='off';
        else
            AdvancedTab.Visible='on';
        end
    end
    if~isequal(get_param([block,'/Core Type'],'LabelModeActiveChoice'),get_param(block,'CoreType'))
        set_param([block,'/Core Type'],'LabelModeActiveChoice',get_param(block,'CoreType'));
    end