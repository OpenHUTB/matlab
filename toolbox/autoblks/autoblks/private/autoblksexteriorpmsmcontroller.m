function[varargout]=autoblksexteriorpmsmcontroller(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'ControlTypePopup'
        ControlTypePopup(Block);
    case 'CalcSpeed'
        CalcSpeed(Block)
    case 'CalcCurrent'
        CalcCurrent(Block)
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'ElectricalLoss'
        ElectricalLoss(Block);
    end
end

function ElectricalLoss(Block)

    param_loss=get_param(Block,'param_loss');
    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff'},{'w_eff_bp','T_eff_bp','losses_table','w_loss_bp','T_loss_bp','efficiency_table'});
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'w_loss_bp','T_loss_bp','losses_table'},{'eff','efficiency_table','w_eff_bp','T_eff_bp'});
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','efficiency_table'},{'eff','w_loss_bp','T_loss_bp','losses_table'});
    end

end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='motor_controller_exterior_pm.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,130,'white');
end

function Initialization(Block)
    PmsmOptions=...
    {'autolibpmsmcommon/Exterior PMSM Speed Control Drive CE','Exterior PMSM Speed Control Drive CE';
    'autolibpmsmcommon/Exterior PMSM Torque Control Drive CE','Exterior PMSM Torque Control Drive CE';
    'autolibpmsmcommon/Exterior PMSM Speed Control Drive TL','Exterior PMSM Speed Control Drive TL';
    'autolibpmsmcommon/Exterior PMSM Torque Control Drive TL','Exterior PMSM Torque Control Drive TL';
    };

    control_type=get_param(Block,'control_type');
    param_loss=get_param(Block,'param_loss');

    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff'},{'w_eff_bp','T_eff_bp','losses_table','w_loss_bp','T_loss_bp','efficiency_table'});
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'w_loss_bp','T_loss_bp','losses_table'},{'eff','efficiency_table','w_eff_bp','T_eff_bp'});
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','efficiency_table'},{'eff','w_loss_bp','T_loss_bp','losses_table'});
    end

    switch control_type
    case 'Speed Control'
        switch param_loss
        case 'Single efficiency measurement'
            autoblksreplaceblock(Block,PmsmOptions,1);
        otherwise
            autoblksreplaceblock(Block,PmsmOptions,3);
        end
    case 'Torque Control'
        switch param_loss
        case 'Single efficiency measurement'
            autoblksreplaceblock(Block,PmsmOptions,2);
        otherwise
            autoblksreplaceblock(Block,PmsmOptions,4);
        end
    end




    ParamList={'Rs',[1,1],{'gt',0};...
    'Ldq',[1,1],{'gt',0};...
    'lambda_pm',[1,1],{'gt',0};...
    'PolePairs',[1,1],{'gt',0};...
    'Mechanical',[1,3],{'gte',0};...
    'T_max',[1,1],{'gt',0};...
    'bp',[1,1],{'gt',0};...
    'EV_current',[1,1],{'gt',0};...
    'Kp_d',[1,1],{'gte',0};...
    'Kp_q',[1,1],{'gte',0};...
    'Ki',[1,1],{'gte',0};...
    'EV_motion',[1,3],{'gt',0};...
    'EV_sf',[1,1],{'gt',0};...
    'ba',[1,1],{'gte',0};...
    'Ksa',[1,1],{'gte',0};...
    'Kisa',[1,1],{'gte',0};...
    'Ksf',[1,1],{'gt',0};...
    'Jcomp',[1,1],{'gte',0};...
    'Fv',[1,1],{'gte',0};...
    'Fs',[1,1],{'gte',0};...
    'Tst',[1,1],{'gt',0};...
    'eff',[1,1],{'gt',0;'lte',100};...
    };

    LookupTblList={{'w_loss_bp',{},'T_loss_bp',{}},'losses_table',{'gte',0};...
    {'w_eff_bp',{'neq',0},'T_eff_bp',{'neq',0}},'efficiency_table',{'gt',0;'lte',100};...
    };

    params=autoblkscheckparams(Block,'Exterior',ParamList,LookupTblList);

    Ldq=autolibgeteditparamval(Block,'Ldq');
    PolePairs=autolibgeteditparamval(Block,'PolePairs');
    T_max=autolibgeteditparamval(Block,'T_max');
    lambda_pm=autolibgeteditparamval(Block,'lambda_pm');
    idq_limits=autoblks_determine_max_current(T_max,PolePairs,lambda_pm);
    autolibseteditparamval(Block,'idq_limits',idq_limits);
    autolibseteditparamval(Block,'Ld',Ldq);
    autolibseteditparamval(Block,'Lq',Ldq);

    switch param_loss
    case 'Tabulated loss data'
        [w,T,pwr]=...
        autoblkstabulatedlosssdata(params.w_loss_bp,params.T_loss_bp,params.losses_table);
        set_param(Block,'x_w_bp',mat2str(w));
        set_param(Block,'x_T_bp',mat2str(T));
        set_param(Block,'x_losses_mat',mat2str(pwr));
    case 'Tabulated efficiency data'
        [w,T,pwr]=...
        autoblkstabulatedefficiencydata(params.w_eff_bp,params.T_eff_bp,params.efficiency_table);
        set_param(Block,'x_w_bp',mat2str(w));
        set_param(Block,'x_T_bp',mat2str(T));
        set_param(Block,'x_losses_mat',mat2str(pwr));
    end

end

function CalcCurrent(Block)
    EV_current=autolibgeteditparamval(Block,'EV_current');
    Ld=autolibgeteditparamval(Block,'Ld');
    Lq=autolibgeteditparamval(Block,'Lq');
    Rs=autolibgeteditparamval(Block,'Rs');
    [Kp_d,Kp_q,Ki]=autoblks_determine_curreg_params(EV_current,Ld,Lq,Rs);
    autolibseteditparamval(Block,'Kp_d',Kp_d);
    autolibseteditparamval(Block,'Kp_q',Kp_q);
    autolibseteditparamval(Block,'Ki',Ki);
end

function CalcSpeed(Block)
    EV_motion=autolibgeteditparamval(Block,'EV_motion');
    Mechanical=autolibgeteditparamval(Block,'Mechanical');
    Tst=autolibgeteditparamval(Block,'Tst');
    EV_sf=autolibgeteditparamval(Block,'EV_sf');
    [ba,Ksa,Kisa,Ksf]=autoblks_determine_spdreg_params(Tst,Tst,Mechanical(1),EV_motion,EV_sf);
    Jcomp=Mechanical(1);
    Fv=Mechanical(2);
    Fs=Mechanical(3);
    autolibseteditparamval(Block,'Ksf',Ksf);
    autolibseteditparamval(Block,'ba',ba);
    autolibseteditparamval(Block,'Ksa',Ksa);
    autolibseteditparamval(Block,'Kisa',Kisa);
    autolibseteditparamval(Block,'Jcomp',Jcomp);
    autolibseteditparamval(Block,'Fv',Fv);
    autolibseteditparamval(Block,'Fs',Fs);
end

function ControlTypePopup(Block)
    control_type=get_param(Block,'control_type');


    switch control_type
    case 'Speed Control'
        autoblksenableparameters(Block,'Mechanical',[],'SpeedControllerContainer',[]);
    case 'Torque Control'
        autoblksenableparameters(Block,[],'Mechanical',[],'SpeedControllerContainer');
    end
end