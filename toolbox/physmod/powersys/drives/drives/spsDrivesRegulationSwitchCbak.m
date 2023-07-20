function varargout=spsDrivesRegulationSwitchCbak(block,reflimit)


    modeSelection=get_param(block,'modeselection');
    Swk=get_param(block,'Swk');
    isSpeedRegulation=strcmp(Swk,'Speed regulation');
    isTorqueRegulation=~isSpeedRegulation;
    isWithCurrentLimiter=strcmp(modeSelection,'With current limiter');
    isWithoutCurrentLimiter=~isWithCurrentLimiter;


    maskObj=Simulink.Mask.get(block);


    if isTorqueRegulation
        baseContainerVisible='on';
        bottomContainer1Visible='on';
    else
        baseContainerVisible='off';
        bottomContainer1Visible='off';
    end
    baseContainer=maskObj.getDialogControl('baseContainer');
    baseContainer.Visible=baseContainerVisible;
    bottomContainer=maskObj.getDialogControl('bottomContainer');
    bottomContainer.Visible=bottomContainer1Visible;

    if isWithCurrentLimiter
        igbtContainerVisible='on';
    else
        igbtContainerVisible='off';
    end
    igbtContainer=maskObj.getDialogControl('igbtContainer');
    igbtContainer.Visible=igbtContainerVisible;

    if(isSpeedRegulation&&isWithoutCurrentLimiter)
        machineContainerVisible='off';
    else
        machineContainerVisible='on';
    end
    machineContainer=maskObj.getDialogControl('machineContainer');
    machineContainer.Visible=machineContainerVisible;

    driveType=get_param(block,'driveType');
    switch driveType
    case 'Rectifier based'
        nbQuadrantsRectVisible='on';
        nbQuadrantsChopVisible='off';
    case 'Chopper based'
        nbQuadrantsRectVisible='off';
        nbQuadrantsChopVisible='on';
    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,driveType,'Drive type'));
    end


    if isWithoutCurrentLimiter
        if isSpeedRegulation
            maskVisibilities={...
            'on',...
            'on',...
            nbQuadrantsRectVisible,...
            nbQuadrantsChopVisible,...
            'on',...
            'off',...
            'off',...
            'off',...
            'off',...
            'off',...
            'off',...
            'off',...
            'off',...
'on'...
            };
        else
            maskVisibilities={...
            'on',...
            'on',...
            nbQuadrantsRectVisible,...
            nbQuadrantsChopVisible,...
            'on',...
            'on',...
            'on',...
            'off',...
            'on',...
            'off',...
            'off',...
            'on',...
            'on',...
'on'...
            };
        end
    else


        maskVisibilities={...
        'on',...
        'on',...
        nbQuadrantsRectVisible,...
        nbQuadrantsChopVisible,...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
'on'...
        };
    end
    set_param(block,'MaskVisibilities',maskVisibilities)






    lim=reflimit;

    switch driveType
    case 'Rectifier based'
        nbQuadrants=get_param(block,'nbQuadrantsRect');
        if strcmp(nbQuadrants,'2')
            SatIa=[0,lim];
        else
            SatIa=[-lim,lim];
        end
    case 'Chopper based'
        nbQuadrants=get_param(block,'nbQuadrantsChop');
        if strcmp(nbQuadrants,'1')
            SatIa=[0,lim];
        else
            SatIa=[-lim,lim];
        end
    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,driveType,'Drive type'));
    end


    if isWithCurrentLimiter
        variant='Current_limit';
    else
        variant='No_current_limit';
    end

    if~isequal(get_param(block,'LabelModeActiveChoice'),variant)
        set_param(block,'LabelModeActiveChoice',variant);
    end

    if nargout==1
        varargout{1}=SatIa;
    end
end