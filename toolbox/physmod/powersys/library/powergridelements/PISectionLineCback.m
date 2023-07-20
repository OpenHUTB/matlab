function PISectionLineCback(block)





    WantPhases=max(1,getSPSmaskvalues(block,{'Phases'}));
    Parameters=Simulink.Mask.get(block).Parameters;
    Measurements=strcmp(get_param(block,'MaskNames'),'Measurements')==1;
    Measurements2=strcmp(get_param(block,'MaskNames'),'Measurements2')==1;

    if WantPhases>1
        Parameters(Measurements).Visible='off';
        Parameters(Measurements2).Visible='on';
    else
        Parameters(Measurements).Visible='on';
        Parameters(Measurements2).Visible='off';
    end

    Conductance=strcmp(get_param(block,'MaskNames'),'Conductance')==1;
    switch get_param(block,'SpecifyConductance')
    case 'on'
        Parameters(Conductance).Visible='on';
    case 'off'
        Parameters(Conductance).Visible='off';
    end