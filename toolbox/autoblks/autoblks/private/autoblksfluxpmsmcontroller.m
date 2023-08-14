function[varargout]=autoblksfluxpmsmcontroller(varargin)



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


    IconInfo.ImageName='motor_controller_interior_pm.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,130,'white');
end

function Initialization(Block)
    PmsmOptions=...
    {'autolibfluxpmsmcommon/Flux PMSM Speed Control Drive CE','Flux PMSM Speed Control Drive CE';
    'autolibfluxpmsmcommon/Flux PMSM Torque Control Drive CE','Flux PMSM Torque Control Drive CE';
    'autolibfluxpmsmcommon/Flux PMSM Speed Control Drive TL','Flux PMSM Speed Control Drive TL';
    'autolibfluxpmsmcommon/Flux PMSM Torque Control Drive TL','Flux PMSM Torque Control Drive TL';
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


    ParamList={'PolePairs',[1,1],{'gt',0};...
    'Kp_d',[1,1],{'gte',0};...
    'Kp_q',[1,1],{'gte',0};...
    'Ki_d',[1,1],{'gte',0};...
    'Ki_q',[1,1],{'gte',0};...
    'Tsm',[1,1],{'gt',0};...
    'Ki_w',[1,1],{'gte',0};...
    'Kp_w',[1,1],{'gte',0};...
    'Jcomp',[1,1],{'gte',0};...
    'Fv',[1,1],{'gte',0};...
    'Fs',[1,1],{'gte',0};...
    'Ksf',[1,1],{'gt',0};...
    'Tst',[1,1],{'gt',0};...
    'eff',[1,1],{'gt',0;'lte',100};...
    };

    LookupTblList={{'id_index',{'lte',0},'iq_index',{}},'lambda_d',{};...
    {'id_index',{'lte',0},'iq_index',{}},'lambda_q',{};...
    {'wbp',{'gte',0},'tbp',{'gte',0}},'id_ref',{'lte',0};...
    {'wbp',{'gte',0},'tbp',{'gte',0}},'iq_ref',{};...
    {'w_loss_bp',{},'T_loss_bp',{}},'losses_table',{'gte',0};...
    {'w_eff_bp',{'neq',0},'T_eff_bp',{'neq',0}},'efficiency_table',{'gt',0;'lte',100};...
    };

    params=autoblkscheckparams(Block,'Interior',ParamList,LookupTblList);

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

function ControlTypePopup(Block)
    control_type=get_param(Block,'control_type');


    switch control_type
    case 'Speed Control'
        autoblksenableparameters(Block,[],[],'SpeedControllerContainer',[]);
    case 'Torque Control'
        autoblksenableparameters(Block,[],[],[],'SpeedControllerContainer');
    end
end