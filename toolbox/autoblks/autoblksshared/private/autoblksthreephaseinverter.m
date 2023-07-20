function[varargout]=autoblksthreephaseinverter(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'EnableInvrtrTempInput'
        EnableInvrtrTempInput(Block);
    case 'CalMapsButtonCallback'
        varargout{1}=CalMapsButtonCallback(Block);
    case 'SwitchingTypePopup'
        SwitchingTypePopup(Block);
    case 'HDLTableTypePopup'
        HDLTableTypePopup(Block);
    case 'HDLExtrapolate'
        HDLExtrapolate(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='inverter_3_phase_vsi.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,300,'white');
end

function Initialization(Block)
    BlockOptions=...
    {'autolibinverter/PhaseVoltNonHDL','PhaseVoltNonHDL';
    'autolibinverter/SwitchNonHDL','SwitchNonHDL';
    'autolibinverter/PhaseVoltHDL','PhaseVoltHDL';
    'autolibinverter/SwitchHDL','SwitchHDL';
    'autolibinverter/PhaseVoltNonHDLWithTemp','PhaseVoltNonHDLWithTemp';
    'autolibinverter/SwitchNonHDLWithTemp','SwitchNonHDLWithTemp';
    };

    SwitchingTypePopup(Block);

    model_type=get_param(Block,'model_type');
    enable_hdl=get_param(Block,'enable_hdl');

    InvrtrTmpInpEnbl=strcmp(get_param(Block,'InvrtrTmpInpEnbl'),'on');

    if autoblkschecksimstopped(Block)
        if isequal(model_type,'Commanded phase voltage')
            if InvrtrTmpInpEnbl
                autoblksreplaceblock(Block,BlockOptions,5);
            elseif isequal(enable_hdl,'on')
                autoblksreplaceblock(Block,BlockOptions,3);
            else
                autoblksreplaceblock(Block,BlockOptions,1);
            end
        elseif isequal(model_type,'Switch inputs')
            if InvrtrTmpInpEnbl
                autoblksreplaceblock(Block,BlockOptions,6);
            elseif isequal(enable_hdl,'on')
                autoblksreplaceblock(Block,BlockOptions,4);
            else
                autoblksreplaceblock(Block,BlockOptions,2);
            end
        else
            error(message('autoblks_shared:autoerrinverter:invalidMask'));
        end
    end

    ParamList={'intPrec',[1,1],{'gt',0};...
    'u1max',[1,1],{'gt','u1min'};...
    'u1min',[1,1],{'lt','u1max'};...
    'u2max',[1,1],{'gt','u2min'};...
    'u2min',[1,1],{'lt','u2max'};...
    };

    if InvrtrTmpInpEnbl
        LookupTblList={{'w_eff_bp',{},'T_eff_bp',{},'Temp_eff_bp',{}},'ploss_table_3d',{'gte',0}};
    else
        LookupTblList={{'w_eff_bp',{},'T_eff_bp',{}},'ploss_table',{'gte',0}};
    end

    autoblkscheckparams(Block,'Three Phase Inverter',ParamList,LookupTblList);

end


function EnableInvrtrTempInput(Block)

    InvrtrTmpInpEnbl=strcmp(get_param(Block,'InvrtrTmpInpEnbl'),'on');
    HDLEnabled=strcmp(get_param(Block,'enable_hdl'),'on');

    if InvrtrTmpInpEnbl
        ContainersOn={'Temp_eff_bp','ploss_table_3d'};
        ContainersOff={'ploss_table'};
        if HDLEnabled
            set_param(Block,'enable_hdl','off');
            HDLTableTypePopup(Block);
        end
        EnableCheckBox(Block,'enable_hdl','off');
    else
        ContainersOn={'ploss_table'};
        ContainersOff={'Temp_eff_bp','ploss_table_3d'};
        EnableCheckBox(Block,'enable_hdl','on');
    end

    autoblksenableparameters(Block,ContainersOn,ContainersOff);

    MO=get_param(Block,'MaskObject');
    if CheckMBCLicense
        Button=MO.getDialogControl('CalMapsButton');
        Button.Visible='on';
        Button.Enabled='on';
    else
        Button=MO.getDialogControl('CalMapsButton');
        Button.Visible='on';
        Button.Enabled='off';
    end

end


function BlockTasks=CalMapsButtonCallback(Block)

    InvrtrTmpInpEnbl=strcmp(get_param(Block,'InvrtrTmpInpEnbl'),'on');

    if InvrtrTmpInpEnbl
        MbcLossTasks=CalLossWithTempMapsButtonCallback(Block);
    else
        MbcLossTasks=CalLossMapsButtonCallback(Block);
    end

    BlockTasks=autoblksCalBlkGroupTask(Block,MbcLossTasks);
    autoblksCalApp(Block,BlockTasks,'autosharedhelp(''tp_inverter_mbc_calibration'')');

end


function MappedInvrtrBlkCal=CalLossMapsButtonCallback(Block)


    TestPlan=autoblksMbcSetupTestplan('MappedInverter-Loss',autoblkssharedFullMbcTemplateName('MappedInverter-Loss.mbt'));
    TestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpLossData'));
    ImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:LossImpDesc'));
    SignalDescription={'w',getString(message('autoblks_shared:autoblkSharedMisc:MotSpd'));...
    'T',getString(message('autoblks_shared:autoblkSharedMisc:MotTrq'));...
    'ploss',getString(message('autoblks_shared:autoblkSharedMisc:PwrLoss'))};

    TestPlan.DatasetObj.ImportDescription=ImportDescription;
    TestPlan.DatasetObj.AddSignalDescription(SignalDescription);

    MappedInvrtrMbcProject=autoblksMbcSetupProject;
    MappedInvrtrMbcProject.TestPlans=TestPlan;


    MappedInvrtrCageProj=autoblksCageSetupProject;
    MappedInvrtrCageProj.TemplateFile=autoblkssharedFullMbcTemplateName('MappedInverter-Loss.cag');
    MappedInvrtrCageProj.AddBpts('w_eff_bp',{@()TestPlan.MdlBndryRange('w')})
    MappedInvrtrCageProj.AddBpts('T_eff_bp',{@()TestPlan.MdlBndryRange('T')})
    MappedInvrtrCageProj.MbcProject=MappedInvrtrMbcProject;


    MappedInvrtrDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksshared',filesep,'mbctemplates'];


    MappedInvrtrBlkCal=autoblksCalSimulinkBlkMbcTask(Block,'CalLossMapData',MappedInvrtrMbcProject,MappedInvrtrCageProj,MappedInvrtrDataDir);
    MappedInvrtrBlkCal.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calInvLossMaps'));

end


function MappedInvrtrBlkCal=CalLossWithTempMapsButtonCallback(Block)


    TestPlan=autoblksMbcSetupTestplan('MappedInverter-LossWithTemp',autoblkssharedFullMbcTemplateName('MappedInverter-LossWithTemp.mbt'));
    TestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpLossData'));
    ImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:LossImpDesc'));
    SignalDescription={'w',getString(message('autoblks_shared:autoblkSharedMisc:MotSpd'));...
    'T',getString(message('autoblks_shared:autoblkSharedMisc:MotTrq'));...
    'ploss',getString(message('autoblks_shared:autoblkSharedMisc:PwrLoss'));...
    'Tmp',getString(message('autoblks_shared:autoblkSharedMisc:MotTmp'))};

    TestPlan.DatasetObj.ImportDescription=ImportDescription;
    TestPlan.DatasetObj.AddSignalDescription(SignalDescription);

    MappedInvrtrMbcProject=autoblksMbcSetupProject;
    MappedInvrtrMbcProject.TestPlans=TestPlan;


    MappedInvrtrCageProj=autoblksCageSetupProject;
    MappedInvrtrCageProj.TemplateFile=autoblkssharedFullMbcTemplateName('MappedInverter-LossWithTemp.cag');
    MappedInvrtrCageProj.AddBpts('w_eff_bp',{@()TestPlan.MdlBndryRange('w')});
    MappedInvrtrCageProj.AddBpts('T_eff_bp',{@()TestPlan.MdlBndryRange('T')});
    MappedInvrtrCageProj.AddNdTbl('ploss_table_3d_1',{'w_eff_bp','T_eff_bp','Temp_eff_bp'});
    MappedInvrtrCageProj.MbcProject=MappedInvrtrMbcProject;


    MappedInvrtrDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksshared',filesep,'mbctemplates'];


    MappedInvrtrBlkCal=autoblksCalSimulinkBlkMbcTask(Block,'CalLossWithTempMapData',MappedInvrtrMbcProject,MappedInvrtrCageProj,MappedInvrtrDataDir);
    MappedInvrtrBlkCal.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calInvLossMaps'));

end

function SwitchingTypePopup(Block)
    model_type=get_param(Block,'model_type');
    switch model_type
    case 'Commanded phase voltage'
        autoblksenableparameters(Block,[],{'fs'});
    case 'Switch inputs'
        autoblksenableparameters(Block,[],{'fs'});
    otherwise
        error(message('autoblks_shared:autoerrinverter:invalidMask'));
    end
    HDLTableTypePopup(Block);
end

function HDLTableTypePopup(Block)

    InvrtrTmpInpEnbl=strcmp(get_param(Block,'InvrtrTmpInpEnbl'),'on');
    enable_hdl=get_param(Block,'enable_hdl');

    switch enable_hdl
    case 'on'
        autoblksenableparameters(Block,{'n1','n2','preExtrapFlag'},[]);
        HDLExtrapolate(Block);
        if InvrtrTmpInpEnbl
            set_param(Block,'InvrtrTmpInpEnbl','off');
            EnableInvrtrTempInput(Block);
        end
        EnableCheckBox(Block,'InvrtrTmpInpEnbl','off');
    case 'off'
        autoblksenableparameters(Block,[],{'n1','n2','preExtrapFlag','u1max','u1min','u2max','u2min'});
        EnableCheckBox(Block,'InvrtrTmpInpEnbl','on');
    otherwise
        error(message('autoblks_shared:autoerrinverter:invalidMask'));
    end

end

function HDLExtrapolate(Block)
    preExtrapFlag=get_param(Block,'preExtrapFlag');
    enable_hdl=get_param(Block,'enable_hdl');
    if isequal(enable_hdl,'off')
        autoblksenableparameters(Block,[],{'u1max','u1min','u2max','u2min'});
    elseif isequal(enable_hdl,'on')&&isequal(preExtrapFlag,'on')
        autoblksenableparameters(Block,{'u1max','u1min','u2max','u2min'},[]);
    elseif isequal(enable_hdl,'on')&&isequal(preExtrapFlag,'off')
        autoblksenableparameters(Block,[],{'u1max','u1min','u2max','u2min'});
    else
        error(message('autoblks_shared:autoerrinverter:invalidMask'));
    end
end


function isMBCInstalled=CheckMBCLicense

    if license('test','MBC_Toolbox')
        isMBCInstalled=true;
    else
        isMBCInstalled=false;
    end

end


function EnableCheckBox(Block,CheckBoxName,CheckBoxState)
    maskNames=get_param(Block,'MaskNames');
    maskEnables=get_param(Block,'MaskEnables');
    [~,ind]=intersect(maskNames,CheckBoxName);
    maskEnables{ind}=CheckBoxState;
    set_param(Block,'MaskEnables',maskEnables);
end