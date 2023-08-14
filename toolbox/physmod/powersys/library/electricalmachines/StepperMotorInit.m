function varargout=StepperMotorInit(block,varargin)








    [TsPowergui,TsBlock,MotorType,NumberOfPhases_1,NumberOfPhases_2,Lmax,Lmin,Step_angle,pos0]=varargin{1:end};


    SM.theta0=pos0*pi/180;

    powerlibroot=which('powersysdomain');
    SPSroot=powerlibroot(1:end-16);

    switch MotorType

    case 'Permanent-magnet / Hybrid'

        SM.p=360/Step_angle/4;

        if NumberOfPhases_1==1
            Phases=2;
        else
            Phases=4;
        end

        SM.icon=fullfile(SPSroot,'hy_stm_2.jpg');

    case 'Variable reluctance'

        if NumberOfPhases_2==1
            Phases=3;
        elseif NumberOfPhases_2==2
            Phases=4;
        else
            Phases=5;
        end
        SM.Nph=Phases;
        SM.L0=(Lmax+Lmin)/2;
        SM.L1=(Lmax-Lmin)/2;
        SM.Nr=360/Step_angle/Phases;
        SM.icon=fullfile(SPSroot,'vr_stm_1b.jpg');
    end


    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    [WantBlockChoice,Ts]=SetInternalModels('get',block,'Stepper Motor',PowerguiInfo,TsPowergui,TsBlock,MotorType,Phases);


    psbloadfunction(block,'gotofrom','Initialize');


    StepperMotorCback(block,1);


    [WantBlockChoice,SM]=SPSrl('userblock','StepperMotor',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    varargout={Ts,SM,WantBlockChoice};
