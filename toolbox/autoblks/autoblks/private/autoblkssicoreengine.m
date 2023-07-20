function varargout=autoblkssicoreengine(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        varargout{1}=Initialization(Block);
    case 'AirMassFlowOptionPopupCallback'
        AirMassFlowOptionPopupCallback(Block);
    case 'TrqOptionPopupCallback'
        TrqOptionPopupCallback(Block);
    case 'BurnedGasCalcPopupCallback'
        BurnedGasCalcPopupCallback(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MassFracSetup'
        MassFracSetup(Block,varargin{3});
    case 'EmissionsCheckboxCallback'
        autoblksemissionssetup(Block,'CheckboxCallback');
    case 'CrkSignalsCheckbox'
        CrkSignalsCheckbox(Block);
    end

end


function M=Initialization(Block)



    ParentBlock=[Block,'/Core Engine Model'];
    BreathingOption={'autolibcoreengcommon/SI Engine Breathing Speed Density','SI Engine Breathing Speed Density';...
    'autolibcoreengcommon/SI Engine Breathing with Cam Phasing','SI Engine Breathing with Cam Phasing'};

    switch get_param(Block,'AirMassFlowOptionPopup')
    case 'Simple Speed-Density'
        autoblksreplaceblock(ParentBlock,BreathingOption,1);
        SwitchInport(Block,'IntkCamPhase',false);
        SwitchInport(Block,'ExhCamPhase',false);
        SwitchInport(Block,'AmbPrs',false);
    case 'Dual-Independent Variable Cam Phasing'
        autoblksreplaceblock(ParentBlock,BreathingOption,2);
        SwitchInport(Block,'IntkCamPhase',true);
        SwitchInport(Block,'ExhCamPhase',true);
        SwitchInport(Block,'AmbPrs',true);
    end


    ParentBlock=[Block,'/Core Engine Model/Engine Combustion Model With Cam Phasing/Engine Torque and Exhaust Temperature Models'];
    TorqueOption={'autolibcoreengcommon/Spark Ignition Torque Simple Lookup','Spark Ignition Torque Simple Lookup';...
    'autolibcoreengcommon/Spark Ignition Torque Structure','Spark Ignition Torque Structure'};
    switch get_param(Block,'TrqOptionPopup')
    case 'Simple Torque Lookup'
        autoblksreplaceblock(ParentBlock,TorqueOption,1);
        SwitchInport(Block,'SpkAdv',false);
        SwitchInport(Block,'Ect',false);
        set_param([Block,'/Core Engine Model/Engine Combustion Model With Cam Phasing/Power Info/Core Engine Power Info'],'TrqMdlType','Simple Torque Lookup')
    case 'Torque Structure'
        autoblksreplaceblock(ParentBlock,TorqueOption,2);
        SwitchInport(Block,'SpkAdv',true);
        SwitchInport(Block,'Ect',true);
        set_param([Block,'/Core Engine Model/Engine Combustion Model With Cam Phasing/Power Info/Core Engine Power Info'],'TrqMdlType','Torque Structure')
    end

    if strcmp(get_param(Block,'TrqOptionPopup'),'Torque Structure')
        if strcmp(get_param(Block,'EnableCrkSignalsCheckbox'),'on')
            set_param([Block,'/Core Engine Model/Engine Combustion Model With Cam Phasing/Engine Torque and Exhaust Temperature Models/Spark Ignition Torque Structure/Crank angle based cylinder pressure and torque'],'LabelModeActiveChoice','1');
        else
            set_param([Block,'/Core Engine Model/Engine Combustion Model With Cam Phasing/Engine Torque and Exhaust Temperature Models/Spark Ignition Torque Structure/Crank angle based cylinder pressure and torque'],'LabelModeActiveChoice','0');
        end
    end



    InportNames={'InjPw';'SpkAdv';'IntkCamPhase';'ExhCamPhase';'AmbPrs';'LdTrq';'EngSpd';'Ect'};

    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end



    SelectedSpecies=autoblksemissionssetup(Block,'ReturnSelectedSpecies');
    M.DefinedExhSpecies=SelectedSpecies;
    MassFracInfo=autoblkssetupengflwmassfrac(Block);


    ParamList={'NCyl',[1,1],{'gte',1;'int',0;'lte',20};...
    'Cps',[1,1],{'gte',1;'int',0;'lte',2};...
    'Vd',[1,1],{'gte',1e-5;'lte',0.1};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'cp_exh',[1,1],{'gte',500;'lte',3000};...
    'Sinj',[1,1],{'gte',1e-6;'lte',1e5};...
    'fuel_lhv',[1,1],{'gt',0.;'lte',200e6};...
    'fuel_sg',[1,1],{'gte',0.2;'lte',1.2};...
    'afr_stoich',[1,1],{'gte',1;'lte',100}};

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
    FricModBpt={'f_fric_temp_bpt',{'gte',0}};

    LookupTblList={
    CylVolVarTblBpt,'f_vivc',{'gte',0.1;'lte',1000};...
    TmCorrVarTblBpt,'f_tm_corr',{'gte',0.;'lte',2.};...
    AirMassFlowVarTblBpt,'f_mdot_intk',{'gte',0;'lte',1e4};...
    AirMassFlowCorrVarTblBpt,'f_mdot_air_corr',{'gte',0;'lte',5};...
    NvVarTblBpt,'f_nv',{'gte',0;'lte',2};...
    TqInrVarTblBpt,'f_tq_inr',{'gte',0;'lte',1e6};...
    TqFricVarTblBpt,'f_tq_fric',{'gte',-1e6;'lte',1e6};...
    TqFricVarTblBpt,'f_tq_pump',{'gte',-1e6;'lte',1e6};...
    TqSAoptVarTblBpt,'f_sa_opt',{'gte',-50;'lte',70};...
    TqmdelSAVarTblBpt,'f_m_sa',{'gte',0;'lte',2};...
    TqmLAMVarTblBpt,'f_m_lam',{'gte',0;'lte',2};...
    TqSimpVarTblBpt,'f_tq_nl',{'gte',-1000;'lte',1e6};...
    TexhVarTblBpt,'f_t_exh',{'gte',200;'lte',4000};...
    FricModBpt,'f_fric_temp_mod',{'gte',0}};


    if strcmp(get_param(Block,'EnableCrkSignalsCheckbox'),'on')
        autoblksgetmaskparms(Block,{'NCyl','Cps'},true);
        CrkParamList={'f_crk_tdc_ang',[1,NCyl],{'gte',0;'int',0;'lte',360*Cps}};
        CrkTblLBpt={'f_crk_n_bpt',{'gte',0;'lte',17e3},'f_crk_l_bpt',{'gte',0;'lte',5},'f_crk_ang_bpt',{'gte',0;'lte',719},'f_crk_firing_frac_bpt',{'gte',-1;'lte',1}};
        CrkLookupList={CrkTblLBpt,'f_crk_prs',{'gte',1;'lte',1e9};...
        CrkTblLBpt,'f_crk_btq',{'gte',-1e6;'lte',1e6}};
    else
        CrkParamList=[];
        CrkLookupList={};
    end

    autoblkscheckparams(Block,'Spark Ignition Core Engine',[ParamList;CrkParamList],[LookupTblList;CrkLookupList]);


    autoblksemissionssetup(Block,'CheckTables');
end



function AirMassFlowOptionPopupCallback(Block)
    VolEffContainer='VolEffTblGroup';
    CamPhaseContainers={'IntkVlvClsdCylTblGroup','CylTrpdMassCorrTblGroup','IntkMassFlwTbl','AirMassFlwCorrTbl'};

    switch get_param(Block,'AirMassFlowOptionPopup')
    case 'Simple Speed-Density'
        autoblksenableparameters(Block,[],[],VolEffContainer,CamPhaseContainers);
    case 'Dual-Independent Variable Cam Phasing'
        autoblksenableparameters(Block,[],[],CamPhaseContainers,VolEffContainer);
    end
end


function TrqOptionPopupCallback(Block)

    LuTblParams={'TrqLuTbl'};
    TrqStructContainers={'LdSpdTblContainer','TrqSpkEffContainer','TrqLambdaContainer','CrkAngSigGroup','EnableCrkSignalsCheckbox'};

    switch get_param(Block,'TrqOptionPopup')
    case 'Simple Torque Lookup'
        autoblksenableparameters(Block,[],[],LuTblParams,TrqStructContainers);
    case 'Torque Structure'
        autoblksenableparameters(Block,[],[],TrqStructContainers,LuTblParams);
        CrkSignalsCheckbox(Block);
    end

end


function CrkSignalsCheckbox(Block)

    if strcmp(get_param(Block,'TrqOptionPopup'),'Torque Structure')
        if strcmp(get_param(Block,'EnableCrkSignalsCheckbox'),'on')
            autoblksenableparameters(Block,[],[],{'CrkAngSigGroup'},[]);
        else
            autoblksenableparameters(Block,[],[],[],{'CrkAngSigGroup'});
        end
    end

end




function BurnedGasCalcPopupCallback(Block)

    switch get_param(Block,'BurnedGasCalcPopup')
    case 'Derive from air-fuel ratio'
        autoblksenableparameters(Block,[],'f_Burned_frac');
    case 'Direct lookup'
        autoblksenableparameters(Block,'f_Burned_frac');
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


function IconInfo=DrawCommands(Block)

    AliasNames={'IntkCamPhase','ICP';...
    'ExhCamPhase','ECP'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='engine_spark_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,30,80,'white');

end


function MassFracSetup(Block,EngFlwBlkObj)
    SelectedSpecies=autoblksemissionssetup(Block,'ReturnSelectedSpecies');
    EngFlwBlkObj.MassFracReqSrc=[SelectedSpecies,'AirMassFrac','BrndGasMassFrac'];
end