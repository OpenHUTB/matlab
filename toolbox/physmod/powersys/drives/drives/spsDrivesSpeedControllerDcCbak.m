function varargout=spsDrivesSpeedControllerDcCbak(block,reflimit)






    driveType=get_param(block,'driveType');




    switch driveType
    case 'Rectifier based'
        nbQuadrants=get_param(block,'nbQuadrantsRect');
        SatRef=[-inf,inf];
    case 'Chopper based'
        nbQuadrants=get_param(block,'nbQuadrantsChop');
        if strcmp(nbQuadrants,'4')
            SatRef=[-inf,inf];
        else
            SatRef=[0,inf];
        end
    otherwise
        error(['Unknown drive type''',driveType,'''.']);
    end






    lim=reflimit;
    switch driveType
    case 'Rectifier based'
        if strcmp(nbQuadrants,'2')
            SatIa=[0,lim];
        else
            SatIa=[-lim,lim];
        end
    case 'Chopper based'
        if strcmp(nbQuadrants,'1')
            SatIa=[0,lim];
        else
            SatIa=[-lim,lim];
        end
    otherwise
        error(['Unknown drive type''',driveType,'''.']);
    end

    switch driveType
    case 'Rectifier based'
        maskEnablesVisibilities={...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
    case 'Chopper based'
        maskEnablesVisibilities={...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
    end
    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnablesVisibilities);
    end
    set_param(block,'MaskVisibilities',maskEnablesVisibilities);

    if nargout>0
        varargout{1}=SatRef;varargout{2}=SatIa;
    end
