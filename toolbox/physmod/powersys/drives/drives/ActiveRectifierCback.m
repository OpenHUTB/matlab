function ActiveRectifierCback(block,action)








    switchType=get_param(block,'Device');

    switch action
    case 'Initialization'
        set_param([block,'/Rectifier_3ph'],'Device',switchType);
    case 'Device configuration'





















        visibilities={'on','on','on','on','on','on','on','on','on','on',...
        'on','off','on','off','off','off','off','off','off'};
        switch switchType
        case 'MOSFET / Diodes'
            visibilities{13}='off';
        case 'GTO / Diodes'
            visibilities{15}='on';
        case 'IGBT / Diodes'
            visibilities{16}='on';
        end
        set_param(block,'MaskVisibilities',visibilities);
    end