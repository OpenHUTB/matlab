function varargout=autoblkscicontroller(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'TrqOptionPopupCallback'
        TrqOptionPopupCallback(Block)
    case 'ESSEnableCallback'
        ESSEnableCallback(Block)
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='propulsion_controller_compression_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,150,'white');
end


function Initialization(Block)


    if autoblkschecksimstopped(Block)
        set_param([Block,sprintf('%s\n%s','/Estimators/Engine AFR and Fuel Calculation/Fuel Mass Engine AFR and',' Fuel Calculation')],'LabelModeActiveChoice','2');
    end



    ParentBlock=[Block,'/Estimators'];
    TorqueOption={'autolibcoreengcommon/Compression Ignition Torque Simple Lookup','Compression Ignition Torque Simple Lookup';...
    'autolibcoreengcommon/Compression Ignition Torque Structure','Compression Ignition Torque Structure'};
    switch get_param(Block,'TrqEstOptionPopup')
    case 'Simple Torque Lookup'
        autoblksreplaceblock(ParentBlock,TorqueOption,1);
    case 'Torque Structure'
        autoblksreplaceblock(ParentBlock,TorqueOption,2);
    end


    if autoblkschecksimstopped(Block)
        if strcmp(get_param(Block,'ESSEnable'),'on')&&strcmp(get_param(Block,'ESSExternalPortEnable'),'on')
            set_param([Block,'/Engine Stop-Start'],'LabelModeActiveChoice','ESSActive');
            SwitchInportConst(Block,'ESSEnable',[],true);
            SwitchInport(Block,'IgSw',true);
        elseif strcmp(get_param(Block,'ESSEnable'),'on')&&strcmp(get_param(Block,'ESSExternalPortEnable'),'off')
            set_param([Block,'/Engine Stop-Start'],'LabelModeActiveChoice','ESSActive');
            SwitchInportConst(Block,'ESSEnable','true',false);
            SwitchInport(Block,'IgSw',true);
        else
            set_param([Block,'/Engine Stop-Start'],'LabelModeActiveChoice','ESSInactive');
            SwitchInportConst(Block,'ESSEnable','false',false);
            SwitchInport(Block,'IgSw',false);
        end
    end


    ParamList={'Sinj',[1,1],{'gte',1e-6;'lt',1e5};...
    'cp_exh',[1,1],{'gte',500;'lte',3000};...
    'afr_stoich',[1,1],{'gte',1;'lte',100};...
    'fuel_lhv',[1,1],{'gte',0.;'lte',200e6};...
    'N_idle',[1,1],{'gte',0;'lte',17e3};...
    'Trq_idlecmd_enable',[1,1],{'gt',0};...
    'Trq_idlecmd_max',[1,1],{'gt',0};...
    'Kp_idle',[1,1],{'gte',0};...
    'Ki_idle',[1,1],{'gte',0};...
    'EngRevLim',[1,1],{'gte',1;'lte',17e3}};

    LookupTblList={{'f_egr_tq_bpt',{},'f_egr_n_bpt',{'gte',0;'lte',17e3}},'f_egrcmd',{'gte',0;'lte',100};...
    {'f_rp_tq_bpt',{},'f_rp_n_bpt',{'gte',0;'lte',17e3}},'f_rpcmd',{};...
    {'f_f_tot_tq_bpt',{},'f_f_tot_n_bpt',{'gte',0;'lte',17e3}},'f_fcmd_tot',{};...
    {'f_main_soi_f_bpt',{'gte',0;'lte',1e6},'f_main_soi_n_bpt',{'gte',0;'lte',17e3}},'f_main_soi',{'gte',-50;'lte',50}};

    autoblkscheckparams(Block,'CI Controller',ParamList,LookupTblList);



    ParamList={'NCyl',[1,1],{'gte',1;'int',0;'lte',20};...
    'Cps',[1,1],{'gte',1;'int',0;'lte',2};...
    'Vd',[1,1],{'gte',1e-5;'lte',30.};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'Sinj',[1,1],{'gte',1e-6;'lte',1e8};...
    'afr_stoich',[1,1],{'gte',1;'lte',100};...
    'f_tqs_f_inj_type',[1,inf],{'gte',0;'int',0;'lte',3};...
    'f_tqs_f_burned_soi_limit',[1,1],{'gte',0;'lte',720.};...
    'f_tqs_exht_post_inj_wall_htc',[1,1],{'gte',0.;'lte',1.e6}};

    NvVarTblBpt={'f_nv_prs_bpt',{'gte',1;'lte',1000},'f_nv_n_bpt',{'gte',0;'lte',17e3}};
    TqsOptTblBpt={'f_tqs_f_bpt',{'gte',0;'lte',1e6},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqsMainSOIEffTblBpt={'f_tqs_mainsoi_delta_bpt',{'gte',-100;'lte',100},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqsMAPEffTblBpt={'f_tqs_map_ratio_bpt',{'gte',0;'lte',5},'f_tqs_lambda_bpt',{'gte',0.8;'lte',10}};
    TqsMATEffTblBpt={'f_tqs_mat_delta_bpt',{'gte',-200;'lte',200},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqsO2EffTblBpt={'f_tqs_o2pct_delta_bpt',{'gte',-30;'lte',30},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqsFuelPressEffTblBpt={'f_tqs_fuelpress_delta_bpt',{'gte',-200;'lte',200},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqsIMEPPostInjCorrTblBpt={'f_tqs_f_post_sum_bpt',{'gte',0;'lte',1000},'f_tqs_soi_post_cent_bpt',{'gte',-1e3;'lte',1e3}};
    TqsFricModBpt={'f_tqs_fric_temp_bpt',{'gte',233.15;'lte',573.15},'f_tqs_n_bpt',{'gte',0;'lte',17e3}};
    TqSimpVarTblBpt={'f_tq_nf_f_bpt',{'gte',0;'lte',1e6},'f_tq_nf_n_bpt',{'gte',0;'lte',17e3}};
    TexhVarTblBpt={'f_t_exh_f_bpt',{'gte',0;'lte',1e6},'f_t_exh_n_bpt',{'gte',0;'lte',17e3}};
    EgrFlowVarTblBpt={'f_egr_stdflow_pr_bpt',{'gte',0.2;'lte',1.},'f_egr_stdflow_egrap_bpt',{'gte',0;'lte',100.}};
    TurboPrVarTblBpt={'f_turbo_pr_stdflow_bpt',{'gte',0.;'lte',1.e6},'f_turbo_pr_corrspd_bpt',{'gte',0.;'lte',1.e6}};
    TurboPrVGTVarTblBpt={'f_turbo_pr_vgtposcorr_bpt',{'gte',0.;'lte',1.}};



    LookupTblList={NvVarTblBpt,'f_nv',{'gt',0;'lte',2};...
    TqSimpVarTblBpt,'f_tq_nf',{'gte',-1e6;'lte',1e6};...
    TqsOptTblBpt,'f_tqs_mainsoi',{'gte',-100;'lte',100};...
    TqsOptTblBpt,'f_tqs_map',{'gte',1000;'lte',5e5};...
    TqsOptTblBpt,'f_tqs_emap',{'gte',1000;'lte',10e5};...
    TqsOptTblBpt,'f_tqs_mat',{'gte',233.15;'lte',1500};...
    TqsOptTblBpt,'f_tqs_o2pct',{'gte',0;'lte',30};...
    TqsOptTblBpt,'f_tqs_fuelpress',{'gte',0;'lte',500};...
    TqsOptTblBpt,'f_tqs_imepg',{'gte',0;'lte',30e6};...
    TqsOptTblBpt,'f_tqs_fmep',{'gte',-1e6;'lte',1e6};...
    TqsOptTblBpt,'f_tqs_pmep',{'gte',-1e6;'lte',1e6};...
    TqsMainSOIEffTblBpt,'f_tqs_mainsoi_eff',{'gt',0.;'lt',2.};...
    TqsMAPEffTblBpt,'f_tqs_map_eff',{'gt',0.;'lt',2.};...
    TqsMATEffTblBpt,'f_tqs_mat_eff',{'gt',0.;'lt',2.};...
    TqsO2EffTblBpt,'f_tqs_o2pct_eff',{'gt',0.;'lt',2.};...
    TqsFuelPressEffTblBpt,'f_tqs_fuelpress_eff',{'gt',0.;'lt',2.};...
    TqsIMEPPostInjCorrTblBpt,'f_tqs_imep_post_corr',{'gte',0.;'lte',1.e6};...
    TqsOptTblBpt,'f_tqs_exht',{'gte',233.15;'lte',1500.};...
    TqsMainSOIEffTblBpt,'f_tqs_exht_mainsoi_eff',{'gt',0.;'lt',2.};...
    TqsMAPEffTblBpt,'f_tqs_exht_map_eff',{'gt',0.;'lt',2.};...
    TqsMATEffTblBpt,'f_tqs_exht_mat_eff',{'gt',0.;'lt',2.};...
    TqsO2EffTblBpt,'f_tqs_exht_o2pct_eff',{'gt',0.;'lt',2.};...
    TqsFuelPressEffTblBpt,'f_tqs_exht_fuelpress_eff',{'gt',0.;'lt',2.};...
    TqsFricModBpt,'f_tqs_fric_temp_mod',{'gt',0.;'lt',1000.};...
    TexhVarTblBpt,'f_t_exh',{'gt',200;'lt',4000};...
    EgrFlowVarTblBpt,'f_egr_stdflow',{'gte',0.;'lt',1e6};...
    TurboPrVarTblBpt,'f_turbo_pr',{'gte',1.;'lt',10.};...
    TurboPrVGTVarTblBpt,'f_turbo_pr_vgtposcorr',{'gte',0.;'lte',3.}};

    autoblkscheckparams(Block,'CI Controller',ParamList,LookupTblList);


    if strcmp(get_param(Block,'ESSEnable'),'on')
        ParamList={'EngStopTime',[1,1],{'gte',0;'lte',1e6};...
        'CatLightOffTime',[1,1],{'gte',0;'lte',1e6};...
        'Ts',[1,1],{'gte',1e-9;'lte',100.}};
        autoblkscheckparams(Block,ParamList,{});
    end

end


function TrqOptionPopupCallback(Block)
    TrqSimpleContainer={'TrqSimpleContainer'};
    TrqStructContainer={'TrqStructContainer'};
    ExhEstTempContainer={'ExhEstTempContainer'};
    ExhEstTempTqsContainer={'ExhEstTempTqsContainer'};

    switch get_param(Block,'TrqEstOptionPopup')
    case 'Simple Torque Lookup'
        autoblksenableparameters(Block,[],[],TrqSimpleContainer,TrqStructContainer);
        autoblksenableparameters(Block,[],[],ExhEstTempContainer,ExhEstTempTqsContainer);
    case 'Torque Structure'
        autoblksenableparameters(Block,[],[],TrqStructContainer,TrqSimpleContainer);
        autoblksenableparameters(Block,[],[],ExhEstTempTqsContainer,ExhEstTempContainer);
    end

end


function ESSEnableCallback(Block)

    ESSParameters={'ESSExternalPortEnable','EngStopTime','CatLightOffTime','Ts'};

    switch get_param(Block,'ESSEnable')
    case 'on'
        autoblksenableparameters(Block,[],[],ESSParameters,{});
    case 'off'
        set_param(Block,'ESSExternalPortEnable','off');
        autoblksenableparameters(Block,[],[],{},ESSParameters);
    end

end


function SwitchInport(Block,PortName,UsePort)

    InportOption={'built-in/Ground',[PortName,' Ground'];...
    'built-in/Inport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'ShowName','off');
    else
        autoblksreplaceblock(Block,InportOption,2);
    end

end


function SwitchInportConst(Block,PortName,Value,UsePort)

    InportOption={'built-in/Constant',[PortName,' Constant'];...
    'built-in/Inport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'ShowName','off');
        set_param(NewBlkHdl,'Value',Value);
    else
        autoblksreplaceblock(Block,InportOption,2);
    end

end



