function varargout=autoblkscimappedengine(varargin)


    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'BoostLagCallback'
        BoostLagCallback(Block);
    case 'EnableEngTempInput'
        EnableEngTempInput(Block);
    case 'CalMapsButtonCallback'
        varargout{1}=CalMapsButtonCallback(Block);
    case 'InputCmdPopupCallback'
        InputCmdPopupCallback(Block);
    case 'TabMeshPlot:Torque'
        Tabmeshplot(Block,'Torque');
    case 'TabMeshPlot:Air'
        Tabmeshplot(Block,'Air');
    case 'TabMeshPlot:Fuel'
        Tabmeshplot(Block,'Fuel');
    case 'TabMeshPlot:Temp'
        Tabmeshplot(Block,'Temp');
    case 'TabMeshPlot:Efficiency'
        Tabmeshplot(Block,'Efficiency');
    case 'TabMeshPlot:HC'
        Tabmeshplot(Block,'HC');
    case 'TabMeshPlot:CO'
        Tabmeshplot(Block,'CO');
    case 'TabMeshPlot:NOx'
        Tabmeshplot(Block,'NOx');
    case 'TabMeshPlot:CO2'
        Tabmeshplot(Block,'CO2');
    case 'TabMeshPlot:PM'
        Tabmeshplot(Block,'PM');
    end

end


function Initialization(Block)

    InputCmdPopupCallback(Block)
    BoostLagCallback(Block)


    ParentBlock=Block;
    BoostDelayOption={'autolibsharedmappedenginescommon/CI Engine Fuel Mass with Boost Lag','CI Engine Fuel Mass with Boost Lag';...
    'autolibsharedmappedenginescommon/CI Engine Fuel Mass without Boost Lag','CI Engine Fuel Mass without Boost Lag'};

    switch get_param(Block,'TurboLagCheckbox')
    case 'on'
        autoblksreplaceblock(ParentBlock,BoostDelayOption,1);
    case 'off'
        autoblksreplaceblock(ParentBlock,BoostDelayOption,2);
    end


    EnableEngTempInput(Block);
    EngTmpInpEnbl=get_param(Block,'EngTmpInpEnbl');
    LoadVar=get_param(Block,'InputCmdPopup');

    if strcmp(EngTmpInpEnbl,'on')
        if autoblkschecksimstopped(Block)
            if strcmp(LoadVar,'Fuel mass')
                set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithTempWithFuel');
            else
                set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithTempWithTorque');
            end
            SwitchInport(Block,'EngTemp',true);
        end
    else
        if autoblkschecksimstopped(Block)
            if strcmp(LoadVar,'Fuel mass')
                set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithoutTempWithFuel');
            else
                set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithoutTempWithTorque');
            end
            SwitchInport(Block,'EngTemp',false);
        end
    end


    AirFlwTableName=[Block,'/Air Flow/Air Flow Table'];
    MaxCmdName=[Block,'/Max Commanded Fuel-Torque/Constant'];

    Inport1Name=find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport','Port','1');
    Inport1Name=Inport1Name{1};

    switch get_param(Block,'InputCmdPopup')
    case 'Fuel mass'
        SetChildParam(AirFlwTableName,'BreakpointsForDimension1','f_tbrake_f_bpt');
        SetChildParam(Inport1Name,'Unit','mg');
        SetChildParam(Inport1Name,'Name','FuelMassCmd');
        SetChildParam(MaxCmdName,'Value','f_tbrake_f_bpt');
    case 'Torque'
        SetChildParam(AirFlwTableName,'BreakpointsForDimension1','f_tbrake_t_bpt');
        SetChildParam(Inport1Name,'Unit','N*m');
        SetChildParam(Inport1Name,'Name','TrqCmd');
        SetChildParam(MaxCmdName,'Value','f_tbrake_t_bpt');
    end


    ParamList={'NCyl',[1,1],{'gte',1;'int',0;'lte',20};...
    'Cps',[1,1],{'gte',1;'int',0;'lte',2};...
    'Vd',[1,1],{'gte',1e-5;'lte',0.1};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'tau_nat',[1,1],{'gt',0};...
    'f_blend_frac',[1,1],{'gt',0;'lte',1};...
    'tau_bst_rising',[1,1],{'gt',0};...
    'tau_bst_falling',[1,1],{'gt',0};...
    'Sg',[1,1],{'gte',0.2;'lte',1.2};...
    'Lhv',[1,1],{'gt',0}};


    LookupTblList=GetLookupTblList(Block);
    autoblkscheckparams(Block,'Mapped CI Engine',ParamList,LookupTblList);

end


function BoostLagCallback(Block)

    switch get_param(Block,'TurboLagCheckbox')
    case 'on'
        autoblksenableparameters(Block,[],[],'TurboLagContainer');
        autoblksenableparameters(Block,[],'tq_blend_frac');
        autoblksenableparameters(Block,'tq_blend_frac',[],[],[],true);
    case 'off'
        autoblksenableparameters(Block,[],[],[],'TurboLagContainer');
    end


end


function[LookupTblList,InputCmdPopupOption]=GetLookupTblList(Block)

    InputCmdPopupOption=get_param(Block,'InputCmdPopup');

    EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');

    switch get_param(Block,'InputCmdPopup')
    case 'Fuel mass'
        if~EngTmpInpEnbl
            TblBpt={'f_tbrake_f_bpt',{'gte',0;'lte',1e3},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}};
        else
            TblBpt={'f_tbrake_f_bpt',{'gte',0;'lte',1e3},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3},'f_tbrake_engtmp_bpt',{'gte',200.;'lte',500.}};
        end
    case 'Torque'
        if~EngTmpInpEnbl
            TblBpt={'f_tbrake_t_bpt',{},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}};
        else
            TblBpt={'f_tbrake_t_bpt',{},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3},'f_tbrake_engtmp_bpt',{'gte',200.;'lte',500.}};
        end
    end

    if~EngTmpInpEnbl

        LookupTblList={TblBpt,'f_tbrake',{'gte',-1e6;'lte',1e6};...
        TblBpt,'f_air',{'gte',0.;'lte',1e4};...
        TblBpt,'f_fuel',{'gte',0.;'lte',1e4};...
        TblBpt,'f_texh',{'gte',233.15;'lte',3e3};...
        TblBpt,'f_eff',{'gte',0.;'lte',3e3};...
        TblBpt,'f_hc',{'gte',0.;'lte',1e4};...
        TblBpt,'f_co',{'gte',0.;'lte',1e4};...
        TblBpt,'f_nox',{'gte',0.;'lte',1e4};...
        TblBpt,'f_co2',{'gte',0.;'lte',1e4};...
        TblBpt,'f_pm',{'gte',0.;'lte',1e4};...
        {'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}},'f_tbrake_boost',{'gte',0}};
    else

        LookupTblList={TblBpt,'f_tbrake_3d',{'gte',-1e6;'lte',1e6};...
        TblBpt,'f_air_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_fuel_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_texh_3d',{'gte',233.15;'lte',3e3};...
        TblBpt,'f_eff_3d',{'gte',0.;'lte',3e3};...
        TblBpt,'f_hc_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_co_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_nox_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_co2_3d',{'gte',0.;'lte',1e4};...
        TblBpt,'f_pm_3d',{'gte',0.;'lte',1e4};...
        {'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}},'f_tbrake_boost',{'gte',0}};
    end

end


function EnableEngTempInput(Block)

    EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');

    ContainersTmpInput={'f_tbrake_engtmp_bpt','f_tbrake_3d','f_air_3d','f_fuel_3d','f_texh_3d','f_eff_3d','f_hc_3d','f_co_3d','f_nox_3d','f_co2_3d','f_pm_3d'};
    ContainersNoTmpInput={'f_tbrake','f_air','f_fuel','f_texh','f_eff','f_hc','f_co','f_nox','f_co2','f_pm'};

    ButtonList={'CalMapsButton','PlotTrq','PlotAir','PlotFuel','PlotExhTemp','PlotEff','PlotHC','PlotCO','PlotNOx','PlotCO2','PlotPM'};

    MO=get_param(Block,'MaskObject');

    if EngTmpInpEnbl>0
        autoblksenableparameters(Block,ContainersTmpInput,ContainersNoTmpInput);
        for i=1:length(ButtonList(:))
            Button=MO.getDialogControl(ButtonList{i});
            Button.Enabled='off';
            Button.Visible='off';
        end
    else
        autoblksenableparameters(Block,ContainersNoTmpInput,ContainersTmpInput);
        for i=1:length(ButtonList(:))
            Button=MO.getDialogControl(ButtonList{i});
            if CheckMBCLicense
                Button.Enabled='on';
            end
            Button.Visible='on';
        end
    end

end


function InputCmdPopupCallback(Block)
    switch get_param(Block,'InputCmdPopup')
    case 'Fuel mass'
        autoblksenableparameters(Block,'f_tbrake_f_bpt','f_tbrake_t_bpt');
    case 'Torque'
        autoblksenableparameters(Block,'f_tbrake_t_bpt','f_tbrake_f_bpt');
    end
end


function SetChildParam(BlkName,ParamName,Value)
    OldValue=get_param(BlkName,ParamName);
    if~strcmp(Value,OldValue)
        set_param(BlkName,ParamName,Value);
    end
end


function Tabmeshplot(Block,Tab)


    [LookupTblList,InputCmdPopupOption]=GetLookupTblList(Block);
    ParamStruct=autoblkscheckparams(Block,[],LookupTblList);
    switch InputCmdPopupOption
    case 'Fuel mass'
        [X,Y]=ndgrid(ParamStruct.f_tbrake_f_bpt,ParamStruct.f_tbrake_n_bpt);
        XAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdFuel'));
        XTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:Fuel'));
    case 'Torque'
        [X,Y]=ndgrid(ParamStruct.f_tbrake_t_bpt,ParamStruct.f_tbrake_n_bpt);
        XAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq'));
        XTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:Trq'));
    end


    switch Tab
    case 'Torque'
        Z=ParamStruct.f_tbrake;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:actTrq'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:ActualTrq'));
    case 'Air'
        Z=ParamStruct.f_air;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:airMassFlw'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:AirMassFlow'));
    case 'Fuel'
        Z=ParamStruct.f_fuel;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:fuelMassFlw'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:FuelMassFlow'));
    case 'Temp'
        Z=ParamStruct.f_texh;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:exhaustTmp'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:ExhTemperature'));
    case 'Efficiency'
        Z=ParamStruct.f_eff;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:BSFC'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:bsfc'));
    case 'HC'
        Z=ParamStruct.f_hc;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:EOHC'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:HC'));
    case 'CO'
        Z=ParamStruct.f_co;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:EOCO'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:CO'));
    case 'NOx'
        Z=ParamStruct.f_nox;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:EONOx'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:NOx'));
    case 'CO2'
        Z=ParamStruct.f_co2;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:EOCO2'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:CO2'));
    case 'PM'
        Z=ParamStruct.f_pm;
        ZAxisName=getString(message('autoblks_shared:autoblkMappedEnginePlot:EOPM'));
        ZTitleName=getString(message('autoblks_shared:autoblkMappedEnginePlot:PM'));
    end


    h=figure('Visible','off');
    surf(X,Y,Z);
    xlabel(XAxisName);
    ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
    zlabel(ZAxisName);
    title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title',ZTitleName,XTitleName)));
    h.Visible='on';
end


function BlockTasks=CalMapsButtonCallback(Block)
    SignalDescription={'EngSpd',getString(message('autoblks_shared:autoblkSharedMisc:EngSpd'));...
    'Torque',getString(message('autoblks_shared:autoblkSharedMisc:Torque'));...
    'FuelMassCmd',getString(message('autoblks_shared:autoblkSharedMisc:FuelMassCmd'));...
    'AirMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:AirMassFlwRate'));...
    'BSFC',getString(message('autoblks_shared:autoblkSharedMisc:BSFC'));...
    'CO2MassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:CO2MassFlwRate'));...
    'COMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:COMassFlwRate'));...
    'ExhTemp',getString(message('autoblks_shared:autoblkSharedMisc:ExhTemp'));...
    'FuelMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:FuelMassFlwRate'));...
    'HCMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:HCMassFlwRate'));...
    'NOxMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:NOxMassFlwRate'));...
    'PMMassFlwRate',getString(message('autoblks_shared:autoblkSharedMisc:PMMassFlwRate'))};
    OptionalSignals={'AirMassFlwRate','BSFC','CO2MassFlwRate','COMassFlwRate',...
    'FuelMassFlwRate','HCMassFlwRate','NOxMassFlwRate','PMMassFlwRate'};
    NonFiringOptionalSignals={'AirMassFlwRate'};
    FiringImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:FiringImpDesc'));
    NonfiringImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:NonFiringImpDesc'));


    if strcmp(get_param(Block,'InputCmdPopup'),'Fuel mass')

        FiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Fuel',fullfile(mbcpath,'mbctraining','MappedEngine-Fuel.mbt'));
        NonfiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Nonfiring',fullfile(mbcpath,'mbctraining','MappedEngine-Nonfiring.mbt'));
        FiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpFiringData'));
        NonfiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpNonFiringData'));
        FiringTestPlan.AddOptionalSignals(OptionalSignals,'0');
        FiringTestPlan.AddOptionalSignals('ExhTemp','300');
        FiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
        FiringTestPlan.DatasetObj.ImportDescription=FiringImportDescription;

        NonfiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
        NonfiringTestPlan.AddOptionalSignals(NonFiringOptionalSignals,'0');
        NonfiringTestPlan.DatasetObj.ImportDescription=NonfiringImportDescription;

        CiMappedEngMbcProject=autoblksMbcSetupProject;
        CiMappedEngMbcProject.TestPlans=[FiringTestPlan,NonfiringTestPlan];


        CiMappedEngCageProj=autoblksCageSetupProject;
        CiMappedEngCageProj.TemplateFile=fullfile(mbcpath,'mbctraining','CIMappedEngine-Fuel.cag');

        SpdBpts={0,@()linspace(FiringTestPlan.MdlLowerBndry('EngSpd'),FiringTestPlan.MdlUpperBndry('EngSpd'),39)};
        FuelBpts={0,@()linspace(FiringTestPlan.MdlUpperBndry('FuelMassCmd')*.02,FiringTestPlan.MdlUpperBndry('FuelMassCmd'),39)};

        CiMappedEngCageProj.AddBpts('f_tbrake_n_bpt',SpdBpts)
        CiMappedEngCageProj.AddBpts('f_tbrake_f_bpt',FuelBpts)
        CiMappedEngCageProj.MbcProject=CiMappedEngMbcProject;
        BlkDataParam='CalMapsFuelCmdData';
    else

        FiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Torque',fullfile(mbcpath,'mbctraining','MappedEngine-Torque.mbt'));
        NonfiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Nonfiring',fullfile(mbcpath,'mbctraining','MappedEngine-Nonfiring.mbt'));
        FiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpFiringData'));
        NonfiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpNonFiringData'));
        FiringTestPlan.AddOptionalSignals(OptionalSignals,'0');
        FiringTestPlan.AddOptionalSignals('ExhTemp','300');
        FiringTestPlan.DatasetObj.ImportDescription=FiringImportDescription;
        FiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);

        NonfiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
        NonfiringTestPlan.AddOptionalSignals(NonFiringOptionalSignals,'0');
        NonfiringTestPlan.DatasetObj.ImportDescription=NonfiringImportDescription;

        CiMappedEngMbcProject=autoblksMbcSetupProject;
        CiMappedEngMbcProject.TestPlans=[FiringTestPlan,NonfiringTestPlan];


        CiMappedEngCageProj=autoblksCageSetupProject;
        CiMappedEngCageProj.TemplateFile=fullfile(mbcpath,'mbctraining','CIMappedEngine-Torque.cag');

        SpdBpts={0,@()linspace(FiringTestPlan.MdlLowerBndry('EngSpd'),FiringTestPlan.MdlUpperBndry('EngSpd'),39)};
        TrqBpts={0,@()linspace(FiringTestPlan.MdlUpperBndry('Torque')*.02,FiringTestPlan.MdlUpperBndry('Torque'),39)};

        CiMappedEngCageProj.AddBpts('f_tbrake_n_bpt',SpdBpts)
        CiMappedEngCageProj.AddBpts('f_tbrake_t_bpt',TrqBpts)
        CiMappedEngCageProj.MbcProject=CiMappedEngMbcProject;
        BlkDataParam='CalMapsTrqCmdData';
    end


    CiMappedEngDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autodemos',filesep,'projectsrc',filesep,'CIDynamometer',filesep,'CalMappedEng'];
    if~exist(CiMappedEngDataDir,'dir')
        CiMappedEngDataDir=pwd;
    end


    CiMappedEngBlkCalTask=autoblksCalSimulinkBlkMbcTask(Block,BlkDataParam,CiMappedEngMbcProject,CiMappedEngCageProj,CiMappedEngDataDir);
    CiMappedEngBlkCalTask.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calEngineMaps'));
    BlockTasks=autoblksCalBlkGroupTask(Block,CiMappedEngBlkCalTask);
    autoblksCalApp(Block,BlockTasks,'autosharedhelp(''ci_mapped_mbc_calibration'')');
end


function IconInfo=DrawCommands(Block)

    IconInfo=autoblksgetportlabels(Block);


    IconInfo.ImageName='engine_mapped_core_ci_shared.png';

    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,100,90,'white');
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


function isMBCInstalled=CheckMBCLicense

    if license('test','MBC_Toolbox')
        isMBCInstalled=true;
    else
        isMBCInstalled=false;
    end

end