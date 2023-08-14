function RLCCback(block)








    BranchType=get_param(block,'BranchType');


    switch BranchType
    case 'Open circuit'
        MaskVisibilities={'on','off','off','off','off','off','off','off','off'};
    case 'R'
        MaskVisibilities={'on','on','off','off','off','off','off','off','on'};
    case 'L'
        MaskVisibilities={'on','off','on','on','off','off','off','off','on'};
        SetInitialInductanceCurrent=strcmp('on',get_param(block,'SetiL0'));
        if SetInitialInductanceCurrent
            MaskVisibilities{5}='on';
        end
    case 'C'
        MaskVisibilities={'on','off','off','off','off','on','on','off','on'};
        SetInitialCapacitanceVoltage=strcmp('on',get_param(block,'Setx0'));
        if SetInitialCapacitanceVoltage
            MaskVisibilities{8}='on';
        end
    case 'RL'
        MaskVisibilities={'on','on','on','on','off','off','off','off','on'};
        SetInitialInductanceCurrent=strcmp('on',get_param(block,'SetiL0'));
        if SetInitialInductanceCurrent
            MaskVisibilities{5}='on';
        end
    case 'RC'
        MaskVisibilities={'on','on','off','off','off','on','on','off','on'};
        SetInitialCapacitanceVoltage=strcmp('on',get_param(block,'Setx0'));
        if SetInitialCapacitanceVoltage
            MaskVisibilities{8}='on';
        end
    case 'LC'
        MaskVisibilities={'on','off','on','on','off','on','on','off','on'};
        SetInitialInductanceCurrent=strcmp('on',get_param(block,'SetiL0'));
        SetInitialCapacitanceVoltage=strcmp('on',get_param(block,'Setx0'));
        if SetInitialInductanceCurrent
            MaskVisibilities{5}='on';
        end
        if SetInitialCapacitanceVoltage
            MaskVisibilities{8}='on';
        end
    case 'RLC'
        MaskVisibilities={'on','on','on','on','off','on','on','off','on'};
        SetInitialInductanceCurrent=strcmp('on',get_param(block,'SetiL0'));
        SetInitialCapacitanceVoltage=strcmp('on',get_param(block,'Setx0'));
        if SetInitialInductanceCurrent
            MaskVisibilities{5}='on';
        end
        if SetInitialCapacitanceVoltage
            MaskVisibilities{8}='on';
        end
    end
    set_param(block,'MaskVisibilities',MaskVisibilities);