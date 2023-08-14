function spsDrivesAutotuningCbak(block,callback,driveType)






    switch callback
    case 'visibility'
        visibilityCtrl(block)
    case 'PICalculator'
        PICalculator(block,driveType)
    end
end



function[]=visibilityCtrl(block)

    handlemask=Simulink.Mask.get(block);
    atButton=handlemask.getDialogControl('autoTuningCtrlbtn');

    if strcmp(atButton.Prompt,'Show Autotuning Control')

        atButton.Prompt='Hide Autotuning Control';
        atGroup=handlemask.getDialogControl('autoTuningContainer');
        atGroup.Visible='on';

    elseif strcmp(atButton.Prompt,'Hide Autotuning Control')

        atButton.Prompt='Show Autotuning Control';
        atGroup=handlemask.getDialogControl('autoTuningContainer');
        atGroup.Visible='off';

    end
end



function PICalculator(block,driveType)



    blockObj=get_param(block,'Object');
    dlg=DAStudio.ToolRoot.getOpenDialogs(blockObj.getDialogSource);

    switch driveType
    case{'AC3','AC4'}


        Rs=str2num(get_param(block,'Rs'));%#ok<*ST2NM>
        Lls=str2num(get_param(block,'Lls'));

        Rr=str2num(get_param(block,'Rr'));
        Llr=str2num(get_param(block,'Llr'));

        Lms=str2num(get_param(block,'Lms'));
        Lr=Llr+Lms;
        Ls=Lls+Lms;
        Ld=Ls;
        Lq=Ls;

        nf=str2num(get_param(gcb,'nf'));

        modulationType=get_param(block,'modulationType');

    case 'AC6'

        Rs=str2num(get_param(block,'Rs'));
        Ld=str2num(get_param(block,'Lls'));
        Lq=str2num(get_param(block,'Lms'));

        modulationType=get_param(block,'modulationType');
    case 'AC7'

        Rs=str2num(get_param(block,'Rs'));
        Ld=str2num(get_param(block,'Lls'));
        Lq=Ld;
        modulationType='';
    end


    J=str2num(get_param(block,'J'));
    B=str2num(get_param(block,'Friction'));
    p=str2num(get_param(block,'p'));


    zeta=str2num(get_param(block,'zeta'));
    Trd=str2num(get_param(block,'Trd'));


    if zeta<0.69
        wn_sc=-1/(zeta*Trd)*log(0.05*sqrt(1-zeta^2));
    else
        wn_sc=0.9257/Trd*exp(1.6341*zeta);
    end




    Kp_sc=(2*zeta*wn_sc*J-B)*pi/30;
    Ki_sc=J*wn_sc^2*pi/30;

    str=sprintf([
    'Speed loop:',...
    '\n   Proportional gain (Kp) = ',num2str(Kp_sc),...
    '\n   Integral gain (Ki) = ',num2str(Ki_sc),...
    '\n   Natural frequency (wn) = ',num2str(wn_sc),' rad/s',...
    '\n   Response time (tr) = ',num2str(Trd),' sec',...
    ]);%#ok<NASGU>

    Kp_sc=round(Kp_sc,3,'significant');
    Ki_sc=round(Ki_sc,3,'significant');
    set_param(block,'kp_sc',num2str(Kp_sc));
    set_param(block,'ki_sc',num2str(Ki_sc));

    dlg.expandTogglePanel('SpeedController',true);
    dlg.expandTogglePanel('PIregulator',true);

    if strcmp(driveType,'AC3')
        trotor=Lr/Rr;


        Kp_flux=(2*zeta*wn_sc*(trotor/Lms)-1/Lms);
        Ki_flux=(trotor/Lms)*wn_sc^2;

        str2=sprintf([
        '\n \nFlux Controller loop:',...
        '\n   Proportional gain (Kp) = ',num2str(Kp_flux),...
        '\n   Integral gain (Ki) = ',num2str(Ki_flux),...
        '\n   Natural frequency (wn) = ',num2str(wn_sc),' rad/s',...
        ]);%#ok<NASGU>
        Kp_flux=round(Kp_flux,3,'significant');
        Ki_flux=round(Ki_flux,3,'significant');
        set_param(block,'kp_fc',num2str(Kp_flux));
        set_param(block,'Ki_fc',num2str(Ki_flux));

        dlg.expandTogglePanel('FieldOrientedControl',true);
        dlg.expandTogglePanel('FluxRegulator',true);

    else
        str2='';%#ok<NASGU>
    end



    if strcmp(modulationType,'SVM')

        bwRatio=str2num(get_param(block,'bwRatio'));
        switch driveType
        case{'AC3','AC6'}

            zeta2=0.5;
            wn2=bwRatio*wn_sc;

            Kp_Iq=(2*zeta2*wn2*Lq-Rs);
            Ki_Iq=Lq*wn2^2;


            Kp_Id=(2*zeta2*wn2*Ld-Rs);
            Ki_Id=Ld*wn2^2;

            str3=sprintf([
            '\n \nq-axis current loop:',...
            '\n   Proportional gain (Kp) = ',num2str(Kp_Iq),...
            '\n   Integral gain (Ki) = ',num2str(Ki_Iq),...
            '\n   Natural frequency (wn) = ',num2str(wn2),' rad/s',...
            '\n \nd-axis current loop:',...
            '\n   Proportional gain (Kp) = ',num2str(Kp_Id),...
            '\n   Integral gain (Ki) = ',num2str(Ki_Id),...
            '\n   Natural frequency (wn) = ',num2str(wn2),' rad/s',...
            ]);%#ok<NASGU>

            Kp_Iq=round(Kp_Iq,3,'significant');
            Ki_Iq=round(Ki_Iq,3,'significant');
            Kp_Id=round(Kp_Id,3,'significant');
            Ki_Id=round(Ki_Id,3,'significant');

            set_param(block,'kp_Iq',num2str(Kp_Iq));
            set_param(block,'ki_Iq',num2str(Ki_Iq));
            set_param(block,'kp_Id',num2str(Kp_Id));
            set_param(block,'ki_Id',num2str(Ki_Id));

            dlg.expandTogglePanel('d_axiscurrentregulator',true);
            dlg.expandTogglePanel('q_axiscurrentregulator',true);

        case 'AC4'
            trotor=Lr/Rr;
            rho=(1-Lms^2/(Ls*Lr));

            zeta2=0.9;
            wn2=bwRatio*wn_sc;
            Kp_flux=(2*zeta2*wn2);
            Ki_flux=wn2^2;


            A=p*(1-rho)*(trotor/Ls)*nf^2;
            B=2*rho*trotor;
            C=(rho*trotor)^2;%#ok<NASGU>

            Kp_Te=(2*zeta2*wn2*B/A-1/A);
            Ki_Te=B/A*wn2^2;

            str3=sprintf([
            '\n \nFlux Controller loop:',...
            '\n   Proportional gain (Kp) = ',num2str(Kp_flux),...
            '\n   Integral gain (Ki) = ',num2str(Ki_flux),...
            '\n   Natural frequency (wn) = ',num2str(wn2),' rad/s',...
            '\n \nTorque Controller loop:',...
            '\n   Proportional gain (Kp) = ',num2str(Kp_Te),...
            '\n   Integral gain (Ki) = ',num2str(Ki_Te),...
            '\n   Natural frequency (wn) = ',num2str(wn2),' rad/s',...
            ]);%#ok<NASGU>

            Kp_flux=round(Kp_flux,3,'significant');
            Ki_flux=round(Ki_flux,3,'significant');
            Kp_Te=round(Kp_Te,3,'significant');
            Ki_Te=round(Ki_Te,3,'significant');

            set_param(block,'kp_flux',num2str(Kp_flux));
            set_param(block,'ki_flux',num2str(Ki_flux));
            set_param(block,'kp_Te',num2str(Kp_Te));
            set_param(block,'ki_Te',num2str(Ki_Te));

            dlg.expandTogglePanel('Torquecontroller',true);
            dlg.expandTogglePanel('Fluxcontroller',true);
        end
    else
        str3='';%#ok<NASGU>
    end



    handlemask=Simulink.Mask.get(block);
    DisplayResults=handlemask.getDialogControl('DisplayResults');
    DisplayResults.Prompt=['--> Natural frequency = ',num2str(wn_sc,5),' rad/s'];

end

