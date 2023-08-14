function[varargout]=autoblksdcdc(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'ElectricalLoss'
        ElectricalLoss(Block);
    end

end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='dc_to_dc.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end

function ElectricalLoss(Block)

    param_loss=get_param(Block,'param_loss');
    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff'},{'v_eff_bp','i_eff_bp','losses_table','v_loss_bp','i_loss_bp','efficiency_table'});
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'v_loss_bp','i_loss_bp','losses_table'},{'eff','efficiency_table','v_eff_bp','i_eff_bp'});
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'v_eff_bp','i_eff_bp','efficiency_table'},{'eff','v_loss_bp','i_loss_bp','losses_table'});
    end

end

function Initialization(Block)
    DcDcOptions=...
    {'autolibdcdccommon/DC to DC Converter Core Single Efficiency Loss','DC to DC Converter Core Single Efficiency Loss';
    'autolibdcdccommon/DC to DC Converter Core Tabular Loss','DC to DC Converter Core Tabular Loss';
    };

    param_loss=get_param(Block,'param_loss');

    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff'},{'v_eff_bp','i_eff_bp','losses_table','v_loss_bp','i_loss_bp','efficiency_table'});
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'v_loss_bp','i_loss_bp','losses_table'},{'eff','efficiency_table','v_eff_bp','i_eff_bp'});
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'v_eff_bp','i_eff_bp','efficiency_table'},{'eff','v_loss_bp','i_loss_bp','losses_table'});
    end

    switch param_loss
    case 'Single efficiency measurement'
        autoblksreplaceblock(Block,DcDcOptions,1);
    otherwise
        autoblksreplaceblock(Block,DcDcOptions,2);
    end

    ParamList={'Tc',[1,1],{'gt',0};...
    'Plimit',[1,1],{'gt',0};...
    'eff',[1,1],{'gt',0;'lte',100};...
    'Vinit',[1,1],{'gte',0};...
    };

    LookupTblList={{'v_loss_bp',{},'i_loss_bp',{}},'losses_table',{'gte',0};...
    {'v_eff_bp',{'neq',0},'i_eff_bp',{'neq',0}},'efficiency_table',{'gt',0;'lte',100};...
    };

    params=autoblkscheckparams(Block,'DC to DC Converter',ParamList,LookupTblList);

    switch param_loss
    case 'Tabulated loss data'
        [v,i,pwr]=...
        autoblkstabulatedlosssdata(params.v_loss_bp,params.i_loss_bp,params.losses_table);
        set_param(Block,'x_v_bp',mat2str(v));
        set_param(Block,'x_i_bp',mat2str(i));
        set_param(Block,'x_losses_mat',mat2str(pwr));
    case 'Tabulated efficiency data'
        [v,i,pwr]=...
        autoblkstabulatedefficiencydata(params.v_eff_bp,params.i_eff_bp,params.efficiency_table);
        set_param(Block,'x_v_bp',mat2str(v));
        set_param(Block,'x_i_bp',mat2str(i));
        set_param(Block,'x_losses_mat',mat2str(pwr));
    end

end
