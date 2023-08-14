function varargout=autoblkssimappedengine(varargin)


    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'CalMapsButtonCallback'
        varargout{1}=CalMapsButtonCallback(Block);
    case 'BoostLagCallback'
        BoostLagCallback(Block);
    case 'EnableEngTempInput'
        EnableEngTempInput(Block);
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

    ParentBlock=Block;
    BoostDelayOption={'autolibsharedmappedenginescommon/SI Engine Torque with Boost Lag','SI Engine Torque with Boost Lag';...
    'autolibsharedmappedenginescommon/SI Engine Torque without Boost Lag','SI Engine Torque without Boost Lag'};

    switch get_param(Block,'TurboLagCheckbox')
    case 'on'
        autoblksreplaceblock(ParentBlock,BoostDelayOption,1);
    case 'off'
        autoblksreplaceblock(ParentBlock,BoostDelayOption,2);
    end


    EnableEngTempInput(Block);
    EngTmpInpEnbl=get_param(Block,'EngTmpInpEnbl');

    if strcmp(EngTmpInpEnbl,'on')
        if autoblkschecksimstopped(Block)
            set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithTemp');
            SwitchInport(Block,'EngTemp',true);
        end
    else
        if autoblkschecksimstopped(Block)
            set_param([Block,'/Mapped Core Engine'],'LabelModeActiveChoice','WithoutTemp');
            SwitchInport(Block,'EngTemp',false);
        end
    end


    ParamList={'NCyl',[1,1],{'gte',1;'int',0;'lte',20};...
    'Cps',[1,1],{'gte',1;'int',0;'lte',2};...
    'Vd',[1,1],{'gte',1e-5;'lte',0.1};...
    'Rair',[1,1],{'gte',250;'lte',320};...
    'Pstd',[1,1],{'gte',99e3;'lte',1.05e5};...
    'Tstd',[1,1],{'gte',230;'lte',300};...
    'tau_thr',[1,1],{'gt',0};...
    'tq_blend_frac',[1,1],{'gt',0;'lte',1};...
    'tau_bst_rising',[1,1],{'gt',0};...
    'tau_bst_falling',[1,1],{'gt',0};...
    'Sg',[1,1],{'gte',0.2;'lte',1.2};...
    'Lhv',[1,1],{'gt',0}};


    if strcmp(EngTmpInpEnbl,'off')

        TblBpt={'f_tbrake_t_bpt',{'gte',-1e6;'lte',1e6},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}};
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

        autoblkscheckparams(Block,'Mapped SI Engine',ParamList,LookupTblList);

    else

        TblBpt={'f_tbrake_t_bpt',{'gte',-1e6;'lte',1e6},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3},'f_tbrake_engtmp_bpt',{'gte',200.;'lte',500.}};

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


        autoblkscheckparams(Block,'Mapped SI Engine',ParamList,LookupTblList);

    end

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



function Tabmeshplot(Block,Tab)

    TblBpt={'f_tbrake_t_bpt',{'gte',-1e6;'lte',1e6},'f_tbrake_n_bpt',{'gte',-17e3;'lte',17e3}};

    switch Tab
    case 'Torque'

        LookupTblList={TblBpt,'f_tbrake',{'gte',-1e6;'lte',1e6}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_tbrake'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_tbrake);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:actTrq')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_Trq')));
        h.Visible='on';

    case 'Air'

        LookupTblList={TblBpt,'f_air',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_air'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_air);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:airMassFlw')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_Air')));
        h.Visible='on';

    case 'Fuel'

        LookupTblList={TblBpt,'f_fuel',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_fuel'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_fuel);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:fuelMassFlw')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_Fuel')));
        h.Visible='on';

    case 'Temp'

        LookupTblList={TblBpt,'f_texh',{'gte',233.15;'lte',3e3}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_texh'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_texh);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:exhaustTmp')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_Temp')));
        h.Visible='on';

    case 'Efficiency'

        LookupTblList={TblBpt,'f_eff',{'gte',0;'lte',3e3}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_eff'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_eff);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:BSFC')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_Eff')));
        h.Visible='on';

    case 'HC'

        LookupTblList={TblBpt,'f_hc',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_hc'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_hc);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:EOHC')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_HC')));
        h.Visible='on';

    case 'CO'

        LookupTblList={TblBpt,'f_co',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_co'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_co);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:EOCO')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_CO')));
        h.Visible='on';

    case 'NOx'

        LookupTblList={TblBpt,'f_nox',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_nox'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_nox);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:EONOx')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_NOx')));
        h.Visible='on';

    case 'CO2'

        LookupTblList={TblBpt,'f_co2',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_co2'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_co2);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:EOCO2')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_CO2')));
        h.Visible='on';

    case 'PM'

        LookupTblList={TblBpt,'f_pm',{'gte',0;'lte',1e4}};
        autoblkscheckparams(Block,'Mapped SI Engine',[],LookupTblList);

        h=figure('Visible','off');
        autoblksgetmaskparms(Block,{'f_tbrake_t_bpt','f_tbrake_n_bpt','f_pm'},true);
        [X,Y]=ndgrid(f_tbrake_t_bpt,f_tbrake_n_bpt);
        surf(X,Y,f_pm);
        xlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:cmdTrq')));
        ylabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:engSpd')));
        zlabel(getString(message('autoblks_shared:autoblkMappedEnginePlot:EOPM')));
        title(getString(message('autoblks_shared:autoblkMappedEnginePlot:title_PM')));
        h.Visible='on';

    end

end


function SiMappedEngBlkCal=CalMapsButtonCallback(Block)


    FiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Torque',fullfile(mbcpath,'mbctraining','MappedEngine-Torque.mbt'));
    NonfiringTestPlan=autoblksMbcSetupTestplan('MappedEngine-Nonfiring',fullfile(mbcpath,'mbctraining','MappedEngine-Nonfiring.mbt'));
    FiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpFiringData'));
    NonfiringTestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpNonFiringData'));
    FiringImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:FiringImpDesc'));
    NonfiringImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:NonFiringImpDesc'));
    SignalDescription={'EngSpd',getString(message('autoblks_shared:autoblkSharedMisc:EngSpd'));...
    'Torque',getString(message('autoblks_shared:autoblkSharedMisc:Torque'));...
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
    FiringTestPlan.AddOptionalSignals(OptionalSignals,'0');
    FiringTestPlan.AddOptionalSignals('ExhTemp','300');
    FiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
    FiringTestPlan.DatasetObj.ImportDescription=FiringImportDescription;

    NonfiringTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
    NonfiringTestPlan.AddOptionalSignals(NonFiringOptionalSignals,'0');
    NonfiringTestPlan.DatasetObj.ImportDescription=NonfiringImportDescription;
    SiMappedEngMbcProject=autoblksMbcSetupProject;
    SiMappedEngMbcProject.TestPlans=[FiringTestPlan,NonfiringTestPlan];


    SiMappedEngCageProj=autoblksCageSetupProject;
    SiMappedEngCageProj.TemplateFile=fullfile(mbcpath,'mbctraining','SIMappedEngine-Torque.cag');
    SpdBpts={0,@()linspace(FiringTestPlan.MdlLowerBndry('EngSpd'),FiringTestPlan.MdlUpperBndry('EngSpd'),39)};
    TrqBpts={0,@()linspace(FiringTestPlan.MdlUpperBndry('Torque')*.02,FiringTestPlan.MdlUpperBndry('Torque'),39)};

    SiMappedEngCageProj.AddBpts('f_tbrake_n_bpt',SpdBpts)
    SiMappedEngCageProj.AddBpts('f_tbrake_t_bpt',TrqBpts)
    SiMappedEngCageProj.MbcProject=SiMappedEngMbcProject;


    SiMappedEngDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autodemos',filesep,'projectsrc',filesep,'SIDynamometer',filesep,'CalMappedEng'];
    if~exist(SiMappedEngDataDir,'dir')
        SiMappedEngDataDir=pwd;
    end


    SiMappedEngBlkCal=autoblksCalSimulinkBlkMbcTask(Block,'CalMapsData',SiMappedEngMbcProject,SiMappedEngCageProj,SiMappedEngDataDir);
    SiMappedEngBlkCal.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calEngineMaps'));
    BlockTasks=autoblksCalBlkGroupTask(Block,SiMappedEngBlkCal);

    autoblksCalApp(Block,BlockTasks,'autosharedhelp(''si_mapped_mbc_calibration'')');
end


function IconInfo=DrawCommands(Block)

    IconInfo=autoblksgetportlabels(Block);


    IconInfo.ImageName='engine_mapped_core_si_shared.png';

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