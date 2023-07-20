function PVArrayCback(block)





    if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))==false
        return
    end



    switch get_param(block,'ModuleName')
    case 'User-defined'
        Enable='on';
    otherwise
        Enable='off';
    end

    Parameters=Simulink.Mask.get(block).Parameters;

    Parameters(strcmp(get_param(block,'MaskNames'),'Ncell')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'Voc')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'Isc')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'Vm')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'Im')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'beta_Voc_pc')==1).Enabled=Enable;
    Parameters(strcmp(get_param(block,'MaskNames'),'alpha_Isc_pc')==1).Enabled=Enable;

    switch get_param(block,'PlotType')
    case 'array @ 1000 W/m2 & specified temperatures'
        V1='off';
        V2='on';
    otherwise
        V1='on';
        V2='off';
    end

    Parameters(strcmp(get_param(block,'MaskNames'),'S_vec')==1).Visible=V1;
    Parameters(strcmp(get_param(block,'MaskNames'),'Temp_C_vec')==1).Visible=V2;

    PowerguiInfo=powericon('getPowerguiInfo',bdroot(block),block);
    MaskObject=Simulink.Mask.get(block);

    Advanced=MaskObject.getDialogControl('Advanced');
    if PowerguiInfo.WantDSS
        Advanced.Visible='off';
    else
        Advanced.Visible='on';
    end

    Tc=strcmp(get_param(block,'MaskNames'),'Tc')==1;
    Tfilter=strcmp(get_param(block,'MaskNames'),'Tfilter')==1;
    RobustModel=strcmp(get_param(block,'MaskNames'),'RobustModel')==1;
    RobustCellTemperature=strcmp(get_param(block,'MaskNames'),'RobustCellTemperature')==1;

    Parameters(Tfilter).Enabled='on';
    Parameters(Tfilter).Visible='on';

    BALteam=MaskObject.getDialogControl('BALteam');
    if PowerguiInfo.Discrete
        Parameters(RobustModel).Visible='on';
        Parameters(RobustCellTemperature).Visible='on';

        switch get_param(block,'RobustModel')
        case 'on'
            Parameters(RobustCellTemperature).Enabled='on';
            BALteam.Visible='off';
        case 'off'
            Parameters(RobustCellTemperature).Enabled='off';
            BALteam.Visible='on';

        end

        Parameters(Tc).Visible='off';

        switch get_param(block,'BAL')
        case 'on'
            Parameters(Tfilter).Enabled='off';
            Parameters(Tfilter).Visible='off';
        case 'off'
            Parameters(Tfilter).Enabled='on';
            Parameters(Tfilter).Visible='on';
        end

    else
        Parameters(RobustModel).Visible='off';
        Parameters(RobustCellTemperature).Visible='off';
        BALteam.Visible='on';
        switch get_param(block,'BAL')
        case 'on'
            Parameters(Tc).Enabled='on';
            Parameters(Tc).Visible='on';
            Parameters(Tfilter).Enabled='off';
        case 'off'
            Parameters(Tc).Enabled='off';
            Parameters(Tc).Visible='on';
            Parameters(Tfilter).Enabled='on';
        end
    end