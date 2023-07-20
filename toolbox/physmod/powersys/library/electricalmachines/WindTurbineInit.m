function[Pnom,Vnom,Fnom,Rs,Lls,Rr,Llr,H,p,F,Wind_On,FACTSroot,mag_IL_init,ph_IL_init,ILd_init,ILq_init,Imax_grid_conv,speed_A,speed_B,speed_C,speed_D,power_A,power_B,power_D,L_RL,R_RL,Kp_volt_reg,Ki_volt_reg,Kp_Q,Ki_Q,Kp_power_reg,Ki_power_reg,Kp_dc_reg,Ki_dc_reg,Kp_grid_side_cur_reg,Ki_grid_side_cur_reg,Kp_rotor_side_cur_reg,Ki_rotor_side_cur_reg,Vcontrol]...
    =WindTurbineInit(nom,sta,rot,mec,ExternalTm,wind_base,block,Pmax,Lchoke,init_inductor,speed_ABCD,power_C,Kpi_volt_reg,Kpi_Q,Kpi_power_reg,Kpi_dc_reg,Kpi_grid_side_cur_reg,Kpi_rotor_side_cur_reg,ControlVQ)








    powerlibroot=which('powersysdomain');
    PSBroot=powerlibroot(1:end-25);
    FACTSroot=fullfile(PSBroot,'DR','DR');
    block=getfullname(block);
    if strcmp('off',ExternalTm)
        Wind_On=1;
    else
        Wind_On=0;
    end


    if any(size(nom)~=[1,3])
        error(message('physmod:powersys:common:InvalidVectorParameter','Nominal power, line-to-line voltage, frequency',block,1,3));
    end

    Pnom=nom(1);
    Vnom=nom(2);
    Fnom=nom(3);


    if Pnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal power','0'));
    end
    if Vnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal line-to-line voltage','0'));
    end
    if Fnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal frequency','0'));
    end


    if any(size(sta)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Stator',block,1,2));
    end

    Rs=sta(1);
    Lls=sta(2);


    if Rs<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Rs','0'));
    end
    if Lls<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Lls','0'));
    end


    if any(size(rot)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Rotor',block,1,2));
    end

    Rr=rot(1);
    Llr=rot(2);


    if Rr<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Rr','0'));
    end
    if Llr<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Llr','0'));
    end


    if any(size(mec)~=[1,3])
        error(message('physmod:powersys:common:InvalidVectorParameter','Inertia constant, friction factor, and pairs of poles',block,1,3));
    end

    H=mec(1);
    F=mec(2);
    p=mec(3);


    if H<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Inertia constant','0'));
    end
    if F<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'friction factor','0'));
    end
    if p<=0
        error(message('physmod:powersys:common:GreaterThan',block,'pairs of poles','0'));
    end


    if~(wind_base>0)
        error(message('physmod:powersys:common:GreaterThan',getfullname(block),'Base wind speed (m/s)',0));
    end


    if any(size(Lchoke)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Grid-side coupling inductor',block,1,2));
    end

    L_RL=Lchoke(1);
    R_RL=Lchoke(2);


    if R_RL<=0
        error(message('physmod:powersys:common:GreaterThan',block,'R','0'));
    end
    if L_RL<=0
        error(message('physmod:powersys:common:GreaterThan',block,'L','0'));
    end


    if any(size(init_inductor)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Coupling inductor initial current',block,1,2));
    end

    mag_IL_init=init_inductor(1);
    ph_IL_init=init_inductor(2)*pi/180;
    [ILd_init,ILq_init]=pol2cart(ph_IL_init,mag_IL_init);


    if Pmax<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Converter maximum power','0'));
    end

    Imax_grid_conv=Pmax;


    if any(size(speed_ABCD)~=[1,4])
        error(message('physmod:powersys:common:InvalidVectorParameter','Tracking characteristic speeds',block,1,4));
    end


    speed_A=speed_ABCD(1);
    speed_B=speed_ABCD(2);
    speed_C=speed_ABCD(3);
    speed_D=speed_ABCD(4);

    if speed_C<=0
        error(message('physmod:powersys:common:GreaterThan',block,'speed_C','0'));
    end

    power_A=0;
    power_B=power_C*(speed_B/speed_C)^3;
    power_D=1;


    if any(size(Kpi_volt_reg)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Grid voltage regulator gains',block,1,2));
    end

    Kp_volt_reg=Kpi_volt_reg(1);
    Ki_volt_reg=Kpi_volt_reg(2);


    if any(size(Kpi_Q)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Reactive power regulator gains',block,1,2));
    end

    Kp_Q=Kpi_Q(1);
    Ki_Q=Kpi_Q(2);


    if any(size(Kpi_power_reg)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Power regulator gains',block,1,2));
    end

    Kp_power_reg=Kpi_power_reg(1);
    Ki_power_reg=Kpi_power_reg(2);


    if any(size(Kpi_dc_reg)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','DC bus voltage regulator gains',block,1,2));
    end

    Kp_dc_reg=Kpi_dc_reg(1);
    Ki_dc_reg=Kpi_dc_reg(2);


    if any(size(Kpi_grid_side_cur_reg)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Grid-side converter current regulator gains',block,1,2));
    end

    Kp_grid_side_cur_reg=Kpi_grid_side_cur_reg(1);
    Ki_grid_side_cur_reg=Kpi_grid_side_cur_reg(2);


    if any(size(Kpi_rotor_side_cur_reg)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Rotor-side converter current regulator gains',block,1,2));
    end

    Kp_rotor_side_cur_reg=Kpi_rotor_side_cur_reg(1);
    Ki_rotor_side_cur_reg=Kpi_rotor_side_cur_reg(2);


    if ControlVQ==1
        Vcontrol=1;
    else
        Vcontrol=0;
    end



    if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))

        Inport_Vref_On=strcmp('Inport',get_param([block,'/Vref '],'BlockType'));
        Inport_Qref_On=strcmp('Inport',get_param([block,'/Qref '],'BlockType'));

        switch get_param(block,'ControlVQ')

        case 'Voltage regulation'

            if Inport_Qref_On
                replace_block(block,'FollowLinks','on','Name','Qref ','Constant','noprompt');
                set_param([block,'/Qref '],'Value','Qref');
            end
            switch get_param(block,'ExternalVref')
            case 'on'
                if~Inport_Vref_On
                    replace_block(block,'FollowLinks','on','Name','Vref ','Inport','noprompt');
                    set_param([block,'/Vref '],'Port','2');
                end
            case 'off'
                if Inport_Vref_On
                    replace_block(block,'FollowLinks','on','Name','Vref ','Constant','noprompt');
                    set_param([block,'/Vref '],'Value','Vref');
                end
            end

        case 'Var regulation'

            if Inport_Vref_On
                replace_block(block,'FollowLinks','on','Name','Vref ','Constant','noprompt');
                set_param([block,'/Vref '],'Value','Vref');
            end
            switch get_param(block,'ExternalQref')
            case 'on'
                if~Inport_Qref_On
                    replace_block(block,'FollowLinks','on','Name','Qref ','Inport','noprompt');
                    set_param([block,'/Qref '],'Port','2');
                end
            case 'off'
                if Inport_Qref_On
                    replace_block(block,'FollowLinks','on','Name','Qref ','Constant','noprompt');
                    set_param([block,'/Qref '],'Value','Qref');
                end
            end

        end

        switch get_param([block,'/Iq_ref '],'BlockType')

        case 'Inport'

            switch get_param(block,'ExternalIqref')
            case 'off'
                replace_block(block,'FollowLinks','on','Name','Iq_ref ','Constant','noprompt');
                set_param([block,'/Iq_ref '],'Value','Iq_ref');
            end

        otherwise

            switch get_param(block,'ExternalIqref')
            case 'on'
                replace_block(block,'FollowLinks','on','Name','Iq_ref ','Inport','noprompt');
                if~(Inport_Vref_On||Inport_Qref_On)
                    set_param([block,'/Iq_ref '],'Port','2');
                else
                    set_param([block,'/Iq_ref '],'Port','3');
                end
            end
        end
    end

    power_initmask();