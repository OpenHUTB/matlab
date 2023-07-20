function[SatRef,SatIa]=DCDriveSpeedRegCback(parent,lim);%#ok








    driveType=get_param(parent,'driveType');
    Swk=get_param([parent,'/Regulation switch'],'Swk');
    switch driveType
    case 'DC1'
        SatRef=[-inf,inf];
        SatIa=[0,lim];
    case 'DC2'
        SatRef=[-inf,inf];
        SatIa=[-lim,lim];
    case 'DC3'
        SatRef=[-inf,inf];
        SatIa=[0,lim];
    case 'DC4'
        SatRef=[-inf,inf];
        SatIa=[-lim,lim];
    case 'DC5'
        SatRef=[0,inf];
        SatIa=[0,lim];
    case 'DC6'
        SatRef=[0,inf];
        SatIa=[-lim,lim];
    case 'DC7'
        SatRef=[-inf,inf];
        SatIa=[-lim,lim];
    end
    if strcmp(Swk,'Speed regulation')
        set_param([parent,'/Speed controller'],'MaskVisibilities',{'on','on','on','on','on','on','on','on','on'})
    elseif strcmp(Swk,'Torque regulation')
        set_param([parent,'/Speed controller'],'MaskVisibilities',{'off','off','off','off','off','off','off','off','off'})
    end

    switch driveType
    case{'DC1','DC2','DC3','DC4','DC5','DC7'}
        if strcmp(Swk,'Speed regulation')
            set_param([parent,'/Regulation switch'],'MaskVisibilities',{'on','off','off','off','off','off','on'})
        elseif strcmp(Swk,'Torque regulation')
            set_param([parent,'/Regulation switch'],'MaskVisibilities',{'on','on','on','on','on','on','on'})
        end
    case 'DC6'
        if strcmp(Swk,'Speed regulation')
            set_param([parent,'/Regulation switch'],'MaskVisibilities',{'on','off','off','on','off','on','on','off','off','on'})
        elseif strcmp(Swk,'Torque regulation')
            set_param([parent,'/Regulation switch'],'MaskVisibilities',{'on','on','on','on','on','on','on','on','on','on'})
        end
    end