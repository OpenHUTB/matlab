function varargout=autoblkssicontroller(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'BreathingOptionPopupCallback'
        BreathingOptionPopupCallback(Block);
    case 'TrqOptionPopupCallback'
        TrqOptionPopupCallback(Block)
    case 'ClsdLpFuelEnCallback'
        ClsdLpFuelEnCallback(Block)
    case 'DitherEnCallback'
        DitherEnCallback(Block)
    case 'LambdaCmdOvrdCallback'
        LambdaCmdOvrdCallback(Block)
    case 'ESSEnableCallback'
        ESSEnableCallback(Block)
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function Initialization(Block)


    if autoblkschecksimstopped(Block)
        set_param([Block,sprintf('%s\n%s','/Controllers/Fuel/AFR/Engine AFR and Fuel Calculation/Fuel Mass Engine AFR and',' Fuel Calculation')],'LabelModeActiveChoice','2');
    end


    if autoblkschecksimstopped(Block)
        if strcmp(get_param(Block,'LambdaCmdOvrd'),'on')
            set_param([Block,'/Controllers/Fuel/AFR Command'],'LabelModeActiveChoice','AFRCommandOverride');
            SwitchInport(Block,'LambdaCmd',true);
        else
            set_param([Block,'/Controllers/Fuel/AFR Command'],'LabelModeActiveChoice','AFRCommand');
            SwitchInport(Block,'LambdaCmd',false);
        end
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


    ParentBlock=[Block,'/Estimators/Intake Air Flow'];
    BreathingOption={'autolibcoreengcommon/SI Engine Breathing Speed Density','SI Engine Breathing Speed Density';...
    'autolibcoreengcommon/SI Engine Breathing with Cam Phasing','SI Engine Breathing with Cam Phasing'};

    switch get_param(Block,'AirEstOptionPopup')
    case 'Simple Speed-Density'
        autoblksreplaceblock(ParentBlock,BreathingOption,1);
    case 'Dual Variable Cam Phasing'
        autoblksreplaceblock(ParentBlock,BreathingOption,2);
    end


    ParentBlock=[Block,'/Estimators/Torque'];
    TorqueOption={'autolibcoreengcommon/Spark Ignition Torque Simple Lookup','Spark Ignition Torque Simple Lookup';...
    'autolibcoreengcommon/Spark Ignition Torque Structure','Spark Ignition Torque Structure'};
    switch get_param(Block,'TrqEstOptionPopup')
    case 'Simple Torque Lookup'
        autoblksreplaceblock(ParentBlock,TorqueOption,1);
    case 'Torque Structure'
        autoblksreplaceblock(ParentBlock,TorqueOption,2);
    end


    autoblksgetmaskparms(Block,{'O2ResetStoichVoltSen','O2ResetMinVoltSen','O2ResetMaxVoltSen','O2ReadyVoltSen'},true);

    ParamList={'Sinj',[1,1],{'gte',1e-6;'lt',1e5};...
    'Nmin',[1,1],{'gt',0;'lte',1000};...
    'afr_stoich',[1,1],{'gte',1;'lte',100};...
    'CrankSpeed',[1,1],{'gte',1.;'lte',6000.};...
    'N_idle',[1,1],{'gte',0;'lte',17e3};...
    'Trq_idlecmd_enable',[1,1],{'gt',0};...
    'Trq_idlecmd_max',[1,1],{'gt',0};...
    'Kp_idle',[1,1],{'gte',0};...
    'Ki_idle',[1,1],{'gte',0};...
    'EngRevLim',[1,1],{'gte',1;'lte',17e3};...
    'ClsdLpFuelPGain',[1,1],{'gte',0.;'lte',1e6};...
    'ClsdLpFuelIGain',[1,1],{'gte',0.;'lte',1e6};...
    'ClsdLpFuelIntgLmt',[1,1],{'gte',0.001;'lte',1};...
    'LambdaDitherAmp',[1,1],{'gte',1e-3;'lte',0.1};...
    'LambdaDitherFrq',[1,1],{'gte',1e-3;'lte',10.};...
    'O2ResetStoichVoltSen',[1,1],{'gte',0.;'lte',100.e3};...
    'O2ResetMinVoltSen',[1,1],{'gte',0.;'lte',O2ResetStoichVoltSen};...
    'O2ResetMaxVoltSen',[1,1],{'gt',O2ResetStoichVoltSen;'lte',100.e3};...
    'O2LearnUpdatePerSen',[1,1],{'gte',0.5;'lte',1000};...
    'O2AmpMinVoltSen',[1,1],{'gte',1;'lte',O2ResetMaxVoltSen-O2ResetMinVoltSen};...
    'O2ReadyVoltSen',[1,1],{'gte',O2ResetMinVoltSen;'lte',O2ResetStoichVoltSen};...
    'O2NotReadyVoltSen',[1,1],{'gt',O2ReadyVoltSen;'lte',O2ResetStoichVoltSen}};



    if strcmp(get_param(Block,'LambdaCmdOvrd'),'off')

        StartupEctBpt={'f_startup_ect_bpt',{'gte',-50.;'lte',100.}};

        LookupTblList={{'f_lcmd_tq_bpt',{},'f_lcmd_n_bpt',{'gte',0;'lte',17e3}},'f_lcmd',{'gte',0;'lt',5};...
        {'f_tap_ld_bpt',{'gte',0;'lt',5},'f_tap_n_bpt',{'gte',0;'lte',17e3}},'f_tap',{'gte',0;'lte',100};...
        {'f_tpp_tap_bpt',{'gte',0;'lte',100}},'f_tpp',{'gte',0;'lte',100};...
        {'f_wap_ld_bpt',{'gte',0;'lt',5},'f_wap_n_bpt',{'gte',0;'lte',17e3}},'f_wap',{'gte',0;'lte',100};...
        {'f_cp_ld_bpt',{'gte',0;'lt',5},'f_cp_n_bpt',{'gte',0;'lte',17e3}},'f_icp',{'gte',-20;'lte',100};...
        {'f_cp_ld_bpt',{'gte',0;'lt',5},'f_cp_n_bpt',{'gte',0;'lte',17e3}},'f_ecp',{'gte',-20;'lte',100};...
        {'f_sa_ld_bpt',{'gte',0;'lt',5},'f_sa_n_bpt',{'gte',0;'lte',17e3}},'f_sa',{'gte',-40;'lte',100};...
        {'f_lamcmd_ld_bpt',{'gte',0;'lt',5},'f_lamcmd_n_bpt',{'gte',0;'lte',17e3}},'f_lamcmd',{'gte',0.3;'lte',5.};...
        StartupEctBpt,'f_startup_lambda_delta',{'gte',0.;'lte',0.9};...
        StartupEctBpt,'f_startup_lambda_delta_timecnst',{'gte',0.;'lte',1200.};...
        {'f_egrpct_ld_bpt',{'gte',0;'lt',5},'f_egrpct_n_bpt',{'gte',0;'lte',17e3}},'f_egrpct_cmd',{'gte',0;'lte',100};...
        {'f_egr_areapct_nrmlzdflow_bpt',{'gte',0;'lte',1},'f_egr_areapct_pr_bpt',{'gte',0.2;'lte',1}},'f_egr_areapct_cmd',{'gte',0;'lte',100};...
        {'f_egr_areapct_pr_bpt',{'gte',0.2;'lte',1}},'f_egr_max_stdflow',{'gte',0};...
        };
    else
        LookupTblList={{'f_lcmd_tq_bpt',{},'f_lcmd_n_bpt',{'gte',0;'lte',17e3}},'f_lcmd',{'gte',0;'lt',5};...
        {'f_tap_ld_bpt',{'gte',0;'lt',5},'f_tap_n_bpt',{'gte',0;'lte',17e3}},'f_tap',{'gte',0;'lte',100};...
        {'f_tpp_tap_bpt',{'gte',0;'lte',100}},'f_tpp',{'gte',0;'lte',100};...
        {'f_wap_ld_bpt',{'gte',0;'lt',5},'f_wap_n_bpt',{'gte',0;'lte',17e3}},'f_wap',{'gte',0;'lte',100};...
        {'f_cp_ld_bpt',{'gte',0;'lt',5},'f_cp_n_bpt',{'gte',0;'lte',17e3}},'f_icp',{'gte',-20;'lte',100};...
        {'f_cp_ld_bpt',{'gte',0;'lt',5},'f_cp_n_bpt',{'gte',0;'lte',17e3}},'f_ecp',{'gte',-20;'lte',100};...
        {'f_sa_ld_bpt',{'gte',0;'lt',5},'f_sa_n_bpt',{'gte',0;'lte',17e3}},'f_sa',{'gte',-40;'lte',100};...
        {'f_egrpct_ld_bpt',{'gte',0;'lt',5},'f_egrpct_n_bpt',{'gte',0;'lte',17e3}},'f_egrpct_cmd',{'gte',0;'lte',100};...
        {'f_egr_areapct_nrmlzdflow_bpt',{'gte',0;'lte',1},'f_egr_areapct_pr_bpt',{'gte',0.2;'lte',1}},'f_egr_areapct_cmd',{'gte',0;'lte',100};...
        {'f_egr_areapct_pr_bpt',{'gte',0.2;'lte',1}},'f_egr_max_stdflow',{'gte',0};...
        };
    end



    autoblkscheckparams(Block,ParamList,LookupTblList);


    ParamList={'NCyl',[1,1],{'gte',1;'int',0;'lte',20};...
    'Cps',[1,1],{'gte',1;'int',0;'lte',2};...
    'Vd',[1,1],{'gte',1e-5;'lte',0.1};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'Sinj',[1,1],{'gte',1e-6;'lte',1e5};...
    'tau_egr',[1,1],{'gt',0}};

    CylVolVarTblBpt={'f_vivc_icp_bpt',{'gte',-5;'lte',60}};
    TmCorrVarTblBpt={'f_tm_corr_nd_bpt',{'gte',0.01;'lte',3},'f_tm_corr_n_bpt',{'gte',0;'lte',17e3}};
    AirMassFlowVarTblBpt={'f_mdot_intk_ecp_bpt',{'gte',-5;'lte',50},'f_mdot_trpd_bpt',{'gte',0.;'lte',1e4}};
    AirMassFlowCorrVarTblBpt={'f_mdot_air_corr_ld_bpt',{'gte',0;'lte',5},'f_mdot_air_n_bpt',{'gte',0.;'lte',17e3}};
    NvVarTblBpt={'f_nv_prs_bpt',{'gte',1;'lte',1000},'f_nv_n_bpt',{'gte',0;'lte',17e3}};
    TqInrVarTblBpt={'f_tq_inr_l_bpt',{'gte',0;'lte',5},'f_tq_inr_n_bpt',{'gte',-100;'lte',17e3}};
    TqFricVarTblBpt={'f_tq_inr_l_bpt',{'gte',0;'lte',5},'f_tq_inr_n_bpt',{'gte',-100;'lte',17e3}};
    TqSAoptVarTblBpt={'f_tq_inr_l_bpt',{'gte',0;'lte',5},'f_tq_inr_n_bpt',{'gte',-100;'lte',17e3}};
    TqmdelSAVarTblBpt={'f_del_sa_bpt',{'gte',0;'lte',60}};
    TqmLAMVarTblBpt={'f_m_lam_bpt',{'gte',0.1;'lte',20}};
    TqSimpVarTblBpt={'f_tq_nl_l_bpt',{'gte',0;'lte',5},'f_tq_nl_n_bpt',{'gte',0;'lte',17e3}};
    TexhVarTblBpt={'f_t_exh_l_bpt',{'gte',0;'lte',5},'f_t_exh_n_bpt',{'gte',0;'lte',17e3}};
    IntkSysFlwBpt={'f_intksys_stdflow_bpt',{'gte',0}};
    EgrStdFlwBpt={'f_egr_stdflow_egrap_bpt',{'gte',0;'lte',100},'f_egr_stdflow_pr_bpt',{'gte',0.2;'lte',1}};

    LookupTblList={
    CylVolVarTblBpt,'f_vivc',{'gte',0.1;'lte',1000};...
    TmCorrVarTblBpt,'f_tm_corr',{'gte',0.;'lte',2.};...
    AirMassFlowVarTblBpt,'f_mdot_intk',{'gte',0;'lte',1e4};...
    AirMassFlowCorrVarTblBpt,'f_mdot_air_corr',{'gte',0;'lte',5};...
    NvVarTblBpt,'f_nv',{'gte',0;'lte',4};...
    TqInrVarTblBpt,'f_tq_inr',{'gte',0;'lte',1e6};...
    TqFricVarTblBpt,'f_tq_fric',{'gte',-1e6;'lte',1e6};...
    TqSAoptVarTblBpt,'f_sa_opt',{'gte',-50;'lte',70};...
    TqmdelSAVarTblBpt,'f_m_sa',{'gte',0;'lte',2};...
    TqmLAMVarTblBpt,'f_m_lam',{'gte',0;'lte',2};...
    TqSimpVarTblBpt,'f_tq_nl',{'gte',-1000;'lte',1e6};...
    TexhVarTblBpt,'f_t_exh',{'gte',200;'lte',4000};...
    IntkSysFlwBpt,'f_intksys_stdflow_pr',{'gte',0.2;'lte',1};...
    EgrStdFlwBpt,'f_egr_stdflow',{'gte',0};...
    };

    autoblkscheckparams(Block,ParamList,LookupTblList);



    if strcmp(get_param(Block,'ESSEnable'),'on')
        ParamList={'EngStopTime',[1,1],{'gte',0;'lte',1e6};...
        'CatLightOffTime',[1,1],{'gte',0;'lte',1e6};...
        'Ts',[1,1],{'gte',1e-9;'lte',100.}};
        autoblkscheckparams(Block,ParamList,{});
    end

end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='propulsion_controller_spark_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,150,'white');
end



function BreathingOptionPopupCallback(Block)
    VolEffContainer='VolEffTblGroup';
    CamPhaseContainers={'IntkVlvClsdCylTblGroup','CylTrpdMassCorrTblGroup','IntkMassFlwTbl','AirMassFlwCorrTbl'};

    switch get_param(Block,'AirEstOptionPopup')
    case 'Simple Speed-Density'
        autoblksenableparameters(Block,[],[],VolEffContainer,CamPhaseContainers);
    case 'Dual Variable Cam Phasing'
        autoblksenableparameters(Block,[],[],CamPhaseContainers,VolEffContainer);
    end
end


function TrqOptionPopupCallback(Block)
    LuTblParams={'TrqLuTbl'};
    TrqStructContainers={'LdSpdTblContainer','TrqSpkEffContainer','TrqLambdaContainer'};

    switch get_param(Block,'TrqEstOptionPopup')
    case 'Simple Torque Lookup'
        autoblksenableparameters(Block,[],[],LuTblParams,TrqStructContainers);
    case 'Torque Structure'
        autoblksenableparameters(Block,[],[],TrqStructContainers,LuTblParams);
    end

end


function ClsdLpFuelEnCallback(Block)

    CLFuelParms={'ClsdLpFuelPGain','ClsdLpFuelIGain','ClsdLpFuelIntgLmt','O2ResetStoichVoltSen','O2ResetMinVoltSen','O2ResetMaxVoltSen','O2LearnUpdatePerSen','O2AmpMinVoltSen','O2ReadyVoltSen','O2NotReadyVoltSen'};

    switch get_param(Block,'ClsdLpFuelEn')
    case 'on'
        autoblksenableparameters(Block,[],[],CLFuelParms,{},true);
        autoblksenableparameters(Block,[],[],{},{'OpenLpDitherEn'},true);
        set_param(Block,'OpenLpDitherEn','on');
    case 'off'
        autoblksenableparameters(Block,[],[],{},CLFuelParms,true);
        autoblksenableparameters(Block,[],[],{'OpenLpDitherEn'},{},true);
        set_param(Block,'OpenLpDitherEn','off');
    end

    DitherEnCallback(Block);

end



function DitherEnCallback(Block)

    DitherParms={'LambdaDitherAmp','LambdaDitherFrq'};

    switch get_param(Block,'OpenLpDitherEn')
    case 'on'
        autoblksenableparameters(Block,[],[],DitherParms,{},true);
    case 'off'
        autoblksenableparameters(Block,[],[],{},DitherParms,true);
    end

end



function LambdaCmdOvrdCallback(Block)

    LambdaParameters={'f_lamcmd','f_lamcmd_ld_bpt','f_lamcmd_n_bpt','f_startup_lambda_delta','f_startup_lambda_delta_timecnst','f_startup_ect_bpt'};

    switch get_param(Block,'LambdaCmdOvrd')
    case 'on'
        autoblksenableparameters(Block,[],[],[],LambdaParameters,true);
    case 'off'
        autoblksenableparameters(Block,[],[],LambdaParameters,[],true);
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
