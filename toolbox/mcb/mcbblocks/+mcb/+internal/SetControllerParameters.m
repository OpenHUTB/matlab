function PI_params=SetControllerParameters(pmsm,inverter,PU_System,T_pwm,Ts,Ts_speed,varargin)

    switch nargin
    case 6
        Delays.Current_Sensor=Ts;
        Delays.Speed_Sensor=Ts;
        Delays.Speed_Filter=(20e-3)*(Ts/50e-6);

        Delays.OM_damping_factor=1/sqrt(2);
        Delays.SO_factor_speed=1.2;

    case 7
        Delays=varargin{1};

    otherwise
        error(message('mcb:blocks:InvalidInputTest'));
    end

    PI_params.T1=Delays.Current_Sensor;
    PI_params.T2=Delays.Speed_Sensor;
    PI_params.delay_IIR=Delays.Speed_Filter;
    PI_params.damping=Delays.OM_damping_factor;
    PI_params.x=Delays.SO_factor_speed;

    pmsm.Rs=pmsm.Rs+inverter.R_board;

    PI_params.sigma=PI_params.T1;

    PI_params.Ti_i=pmsm.Lq/pmsm.Rs;
    PI_params.Ti_id=pmsm.Ld/pmsm.Rs;

    if(PI_params.sigma>=PI_params.Ti_i)
        warning(message('mcb:blocks:LowPWMFrequency'));

    end

    if(PI_params.sigma>=PI_params.Ti_id)
        warning(message('mcb:blocks:LowPWMFrequency'));
    end
    PI_params.Kp_i=(pmsm.Lq*PU_System.I_base)/(4*(PI_params.damping^2)*PI_params.sigma*PU_System.V_base);
    PI_params.Ki_i=(pmsm.Rs*PU_System.I_base)/(4*(PI_params.damping^2)*PI_params.sigma*PU_System.V_base);
    PI_params.Kp_id=(pmsm.Ld*PU_System.I_base)/(4*(PI_params.damping^2)*PI_params.sigma*PU_System.V_base);
    PI_params.Ki_id=(pmsm.Rs*PU_System.I_base)/(4*(PI_params.damping^2)*PI_params.sigma*PU_System.V_base);

    PI_params.Ki_texas=PI_params.Ki_i*Ts/PI_params.Kp_i;
    PI_params.Ki_d_texas=PI_params.Ki_id*Ts/PI_params.Kp_id;
    PI_params.delta=2*PI_params.sigma-0.5*Ts;
    PI_params.delta=10*(2*PI_params.sigma+Ts)+Ts_speed+PI_params.T2+PI_params.delay_IIR;
    PI_params.delta=10*(2*PI_params.sigma+0.5*Ts+Ts_speed)+PI_params.T2+PI_params.delay_IIR;
    PI_params.Ti_speed=((PI_params.x)^2)*PI_params.delta;
    PI_params.Kp_speed=(pmsm.J/(PI_params.x*PI_params.delta))*PU_System.N_base;
    PI_params.Ki_speed=(PI_params.Kp_speed/PI_params.Ti_speed);
    PI_params.Ki_speed_texas=PI_params.Ki_speed*Ts_speed/PI_params.Kp_speed;
    PI_params.gamma=PI_params.delta+PI_params.delay_IIR;
    PI_params.Kp_fwc=(pmsm.Lq*PU_System.I_base)/(2*PI_params.gamma*PU_System.V_base);
    PI_params.Ki_fwc=(pmsm.Rs*PU_System.I_base)/(2*PI_params.gamma*PU_System.V_base);

    PI_params.gamma=Ts+PI_params.delay_IIR;
    PI_params.Ti_fwc=PI_params.Ti_i;

    PI_params.Kp_fwc=(PI_params.Ti_fwc)/(2*PI_params.gamma);
    PI_params.Ki_fwc=(PI_params.Kp_fwc)/(PI_params.Ti_fwc);

end