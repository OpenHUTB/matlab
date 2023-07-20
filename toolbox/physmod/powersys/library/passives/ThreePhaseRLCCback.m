function ThreePhaseRLCCback(block)








    BranchType=get_param(block,'BranchType');































































































    switch BranchType
    case 'Open circuit'
        MaskVisibilities={'on','off','off','off','off'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'R'
        MaskVisibilities={'on','on','off','off','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'L'
        MaskVisibilities={'on','off','on','off','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'C'
        MaskVisibilities={'on','off','off','on','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'RL'
        MaskVisibilities={'on','on','on','off','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'RC'
        MaskVisibilities={'on','on','off','on','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'LC'
        MaskVisibilities={'on','off','on','on','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    case 'RLC'
        MaskVisibilities={'on','on','on','on','on'};
        set_param(block,'MaskVisibilities',MaskVisibilities);
    end