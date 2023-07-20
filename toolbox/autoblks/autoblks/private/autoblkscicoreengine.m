function varargout=autoblkscicoreengine(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        varargout{1}=Initialization(Block);
    case 'IncludeCrkDynCallback'
        IncludeCrkDynCallback(Block);
    case 'TrqOptionPopupCallback'
        TrqOptionPopupCallback(Block)
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MassFracSetup'
        MassFracSetup(Block,varargin{3});
    case 'EmissionsCheckboxCallback'
        autoblksemissionssetup(Block,'CheckboxCallback');
    end

end


function M=Initialization(Block)


    ParentBlock=[Block,'/CI Core Engine/Engine Combustion Model/Engine Torque and Temperature Models'];
    TorqueOption={'autolibcoreengcommon/Compression Ignition Torque Simple Lookup','Compression Ignition Torque Simple Lookup';...
    'autolibcoreengcommon/Compression Ignition Torque Structure','Compression Ignition Torque Structure'};

    switch get_param(Block,'TrqOptionPopup')
    case 'Simple Torque Lookup'
        autoblksreplaceblock(ParentBlock,TorqueOption,1);
        SwitchInport(Block,'Soi',false);
        SwitchInport(Block,'Ect',false);
        SwitchInport(Block,'FuelPrs',false);
        set_param([Block,'/CI Core Engine/Engine Combustion Model/Subsystem/Core Engine Power Info'],'TrqMdlType','Simple Torque Lookup')
    case 'Torque Structure'
        autoblksreplaceblock(ParentBlock,TorqueOption,2);
        SwitchInport(Block,'Soi',true);
        SwitchInport(Block,'Ect',true);
        SwitchInport(Block,'FuelPrs',true);
        set_param([Block,'/CI Core Engine/Engine Combustion Model/Subsystem/Core Engine Power Info'],'TrqMdlType','Torque Structure')
    end



    InportNames={'FuelMass';'Soi';'EngSpd';'FuelPrs';'Ect'};

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
    'Vd',[1,1],{'gte',1e-5;'lte',30.};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'cp_exh',[1,1],{'gte',500;'lte',3000};...
    'afr_stoich',[1,1],{'gte',1;'lte',100};...
    'fuel_lhv',[1,1],{'gt',0.;'lte',200e6};...
    'fuel_sg',[1,1],{'gte',0.2;'lte',1.2};...
    'f_tqs_f_inj_type',[1,inf],{'gte',0;'int',0;'lte',3};...
    'f_tqs_f_burned_soi_limit',[1,1],{'gte',0;'lte',720.};...
    'f_tqs_exht_post_inj_wall_htc',[1,1],{'gte',0.;'lte',1e6}};


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

    LookupTblList={NvVarTblBpt,'f_nv',{'gt',0;'lte',4};...
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
    TexhVarTblBpt,'f_t_exh',{'gt',200;'lt',4000}};

    autoblkscheckparams(Block,ParamList,LookupTblList);


    autoblksemissionssetup(Block,'CheckTables');
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


function TrqOptionPopupCallback(Block)
    TrqSimpleContainer={'TrqSimpleContainer'};
    TrqStructContainer={'TrqStructContainer'};
    ExhTempContainer={'ExhTempContainer'};
    ExhTempTqsContainer={'ExhTempTqsContainer'};


    switch get_param(Block,'TrqOptionPopup')
    case 'Simple Torque Lookup'
        autoblksenableparameters(Block,[],[],TrqSimpleContainer,TrqStructContainer);
        autoblksenableparameters(Block,[],[],ExhTempContainer,ExhTempTqsContainer);
    case 'Torque Structure'
        autoblksenableparameters(Block,[],[],TrqStructContainer,TrqSimpleContainer);
        autoblksenableparameters(Block,[],[],ExhTempTqsContainer,ExhTempContainer);
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


function IconInfo=DrawCommands(Block)

    IconInfo=autoblksgetportlabels(Block);


    IconInfo.ImageName='engine_compression_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,50,80,'white');
end


function MassFracSetup(Block,EngFlwBlkObj)
    SelectedSpecies=autoblksemissionssetup(Block,'ReturnSelectedSpecies');
    EngFlwBlkObj.MassFracReqSrc=[SelectedSpecies,'AirMassFrac','BrndGasMassFrac'];
end