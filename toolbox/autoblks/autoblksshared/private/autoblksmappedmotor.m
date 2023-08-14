function[varargout]=autoblksmappedmotor(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'PortConfig'
        PortConfig(Block);
    case 'ElectricalTorque'
        ElectricalTorque(Block);
    case 'ElectricalLoss'
        ElectricalLoss(Block);
    case 'CalMapsButtonCallback'
        varargout{1}=CalMapsButtonCallback(Block);
    end

end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='mapped_motor_generic.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end

function PortConfig(Block)
    port_config=get_param(Block,'port_config');
    switch port_config
    case 'Torque'
        autoblksenableparameters(Block,[],[],'Mechanical',[]);
    case 'Speed'
        autoblksenableparameters(Block,[],[],[],'Mechanical');
    end
end

function ElectricalLoss(Block)

    param_loss=get_param(Block,'param_loss');

    MO=get_param(Block,'MaskObject');
    Button=MO.getDialogControl('CalMapsButton');

    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff','w_eff','T_eff','Piron','Pbase'},{'w_eff_bp','T_eff_bp','losses_table','losses_table_3d','efficiency_table','efficiency_table_3d','Temp_eff_bp'});
        Button.Enabled='off';
        Button.Visible='off';
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','losses_table'},{'eff','w_eff','T_eff','Piron','Pbase','efficiency_table','efficiency_table_3d','losses_table_3d','Temp_eff_bp'});
        Button.Enabled='on';
        Button.Visible='on';
    case 'Tabulated loss data with temperature'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','Temp_eff_bp','losses_table_3d'},{'eff','w_eff','T_eff','Piron','Pbase','efficiency_table','efficiency_table_3d','losses_table'});
        Button.Enabled='on';
        Button.Visible='on';
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','efficiency_table'},{'eff','w_eff','T_eff','Piron','Pbase','losses_table','losses_table_3d','efficiency_table_3d','Temp_eff_bp'});
        Button.Enabled='off';
        Button.Visible='off';
    case 'Tabulated efficiency data with temperature'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','Temp_eff_bp','efficiency_table_3d'},{'eff','w_eff','T_eff','Piron','Pbase','losses_table','losses_table_3d','efficiency_table'});
        Button.Enabled='off';
        Button.Visible='off';
    end

end

function ElectricalTorque(Block)
    param_by=get_param(Block,'param_by');
    switch param_by
    case 'Tabulated torque-speed envelope'
        autoblksenableparameters(Block,{'w_t','T_t'},{'torque_max','power_max'});
    case 'Maximum torque and power'
        autoblksenableparameters(Block,{'torque_max','power_max'},{'w_t','T_t'});
    end
end

function Initialization(Block)
    MotorOptions=...
    {'autolibmappedmotorcommon/Mapped Motor Core Torque 1','Mapped Motor Core Torque 1';
    'autolibmappedmotorcommon/Mapped Motor Core Torque 2','Mapped Motor Core Torque 2';
    'autolibmappedmotorcommon/Mapped Motor Core Torque 3','Mapped Motor Core Torque 3';
    'autolibmappedmotorcommon/Mapped Motor Core Torque 4','Mapped Motor Core Torque 4';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 1','Mapped Motor Core Speed 1';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 2','Mapped Motor Core Speed 2';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 3','Mapped Motor Core Speed 3';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 4','Mapped Motor Core Speed 4';
    'autolibmappedmotorcommon/Mapped Motor Core Torque 5','Mapped Motor Core Torque 5';
    'autolibmappedmotorcommon/Mapped Motor Core Torque 6','Mapped Motor Core Torque 6';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 5','Mapped Motor Core Speed 5';
    'autolibmappedmotorcommon/Mapped Motor Core Speed 6','Mapped Motor Core Speed 6';
    };

    port_config=get_param(Block,'port_config');
    param_by=get_param(Block,'param_by');
    param_loss=get_param(Block,'param_loss');

    switch port_config
    case 'Torque'
        autoblksenableparameters(Block,[],[],'Mechanical',[]);
    case 'Speed'
        autoblksenableparameters(Block,[],[],[],'Mechanical');
    end

    switch param_by
    case 'Tabulated torque-speed envelope'
        autoblksenableparameters(Block,{'w_t','T_t'},{'torque_max','power_max'});
    case 'Maximum torque and power'
        autoblksenableparameters(Block,{'torque_max','power_max'},{'w_t','T_t'});
    end

    switch param_loss
    case 'Single efficiency measurement'
        autoblksenableparameters(Block,{'eff','w_eff','T_eff','Piron','Pbase'},{'w_eff_bp','T_eff_bp','losses_table','efficiency_table'});
    case 'Tabulated loss data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','losses_table'},{'eff','w_eff','T_eff','Piron','Pbase','efficiency_table'});
    case 'Tabulated loss data with temperature'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','Temp_eff_bp','losses_table_3d'},{'eff','w_eff','T_eff','Piron','Pbase','efficiency_table','efficiency_table_3d','losses_table'});
    case 'Tabulated efficiency data'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','efficiency_table'},{'eff','w_eff','T_eff','Piron','Pbase','losses_table'});
    case 'Tabulated efficiency data with temperature'
        autoblksenableparameters(Block,{'w_eff_bp','T_eff_bp','Temp_eff_bp','efficiency_table_3d'},{'eff','w_eff','T_eff','Piron','Pbase','losses_table','losses_table_3d','efficiency_table'});
    end

    if autoblkschecksimstopped(Block)
        switch port_config
        case 'Torque'
            switch param_by
            case 'Tabulated torque-speed envelope'
                switch param_loss
                case 'Single efficiency measurement'
                    autoblksreplaceblock(Block,MotorOptions,3);
                case 'Tabulated loss data'
                    autoblksreplaceblock(Block,MotorOptions,4);
                case 'Tabulated efficiency data'
                    autoblksreplaceblock(Block,MotorOptions,4);
                case 'Tabulated loss data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,10);
                case 'Tabulated efficiency data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,10);
                end
            otherwise
                switch param_loss
                case 'Single efficiency measurement'
                    autoblksreplaceblock(Block,MotorOptions,1);
                case 'Tabulated loss data'
                    autoblksreplaceblock(Block,MotorOptions,2);
                case 'Tabulated efficiency data'
                    autoblksreplaceblock(Block,MotorOptions,2);
                case 'Tabulated loss data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,9);
                case 'Tabulated efficiency data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,9);
                end
            end
        case 'Speed'
            switch param_by
            case 'Tabulated torque-speed envelope'
                switch param_loss
                case 'Single efficiency measurement'
                    autoblksreplaceblock(Block,MotorOptions,7);
                case 'Tabulated loss data'
                    autoblksreplaceblock(Block,MotorOptions,8);
                case 'Tabulated efficiency data'
                    autoblksreplaceblock(Block,MotorOptions,8);
                case 'Tabulated loss data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,12);
                case 'Tabulated efficiency data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,12);
                end
            otherwise
                switch param_loss
                case 'Single efficiency measurement'
                    autoblksreplaceblock(Block,MotorOptions,5);
                case 'Tabulated loss data'
                    autoblksreplaceblock(Block,MotorOptions,6);
                case 'Tabulated efficiency data'
                    autoblksreplaceblock(Block,MotorOptions,6);
                case 'Tabulated loss data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,11);
                case 'Tabulated efficiency data with temperature'
                    autoblksreplaceblock(Block,MotorOptions,11);
                end
            end
        end
    end

    ParamList={'torque_max',[1,1],{'gt',0};...
    'power_max',[1,1],{'gt',0};...
    'Tc',[1,1],{'gt',0};...
    'eff',[1,1],{'gt',0;'lte',100};...
    'w_eff',[1,1],{'gt',0};...
    'T_eff',[1,1],{'gt',0};...
    'Piron',[1,1],{'gte',0};...
    'Pbase',[1,1],{'gte',0};...
    'J',[1,1],{'gt',0};...
    'b',[1,1],{'gte',0};...
    'omega_o',[1,1],{'gte',0};...
    };

    switch param_loss

    case{'Tabulated loss data with temperature','Tabulated efficiency data with temperature'}

        autoblksgetmaskparms(Block,{'w_eff_bp','T_eff_bp','Temp_eff_bp'},true);

        if strcmp(param_loss,'Tabulated loss data with temperature')

            LookupTblList={{'w_t',{}},'T_t',{};...
            {'w_eff_bp',{},'T_eff_bp',{},'Temp_eff_bp',{}},'losses_table_3d',{'gte',0}};

        else

            LookupTblList={{'w_t',{}},'T_t',{};...
            {'w_eff_bp',{},'T_eff_bp',{},'Temp_eff_bp',{}},'efficiency_table_3d',{'gt',0;'lte',100}};

        end

    otherwise

        LookupTblList={{'w_t',{}},'T_t',{};...
        {'w_eff_bp',{},'T_eff_bp',{}},'losses_table',{'gte',0};...
        {'w_eff_bp',{},'T_eff_bp',{}},'efficiency_table',{'gt',0;'lte',100};...
        };
    end

    params=autoblkscheckparams(Block,'Mapped Motor',ParamList,LookupTblList);

    if strcmp(param_by,'Tabulated torque-speed envelope')
        tabulated_torque_speed(Block,params.T_t,params.w_t);
    end

    switch param_loss
    case 'Single efficiency measurement'

        single_efficiency_measurement(Block,params.Pbase,params.Piron,params.eff,params.w_eff,params.T_eff);

    case 'Tabulated loss data'

        [x_w_tmp,x_T_tmp,x_losses_tmp]=...
        autoblkstabulatedlosssdata(params.w_eff_bp,params.T_eff_bp,params.losses_table);
        set_param(Block,'x_w_eff_vec',mat2str(x_w_tmp));
        set_param(Block,'x_T_eff_vec',mat2str(x_T_tmp));
        set_param(Block,'x_losses_mat',mat2str(x_losses_tmp));

    case 'Tabulated loss data with temperature'

        autoblksgetmaskparms(Block,{'Temp_eff_bp','losses_table_3d'},true);

        NDStr=['cat(',num2str(length(Temp_eff_bp)),','];

        for i=1:length(Temp_eff_bp)
            [x_w_tmp,x_T_tmp,x_losses_tmp]=...
            autoblkstabulatedlosssdata(params.w_eff_bp,params.T_eff_bp,losses_table_3d(:,:,i));
            NDStr=[NDStr,mat2str(x_losses_tmp),','];
        end

        NDStr(end)=')';

        set_param(Block,'x_w_eff_vec',mat2str(x_w_tmp));
        set_param(Block,'x_T_eff_vec',mat2str(x_T_tmp));
        set_param(Block,'x_tmp_eff_vec',mat2str(Temp_eff_bp));
        set_param(Block,'x_losses_mat_3d',NDStr);

    case 'Tabulated efficiency data'

        [x_w_tmp,x_T_tmp,x_losses_tmp]=...
        autoblkstabulatedefficiencydata(params.w_eff_bp,params.T_eff_bp,params.efficiency_table);
        set_param(Block,'x_w_eff_vec',mat2str(x_w_tmp));
        set_param(Block,'x_T_eff_vec',mat2str(x_T_tmp));
        set_param(Block,'x_losses_mat',mat2str(x_losses_tmp));

    case 'Tabulated efficiency data with temperature'

        autoblksgetmaskparms(Block,{'Temp_eff_bp','efficiency_table_3d'},true);

        NDStr=['cat(',num2str(length(Temp_eff_bp)),','];

        for i=1:length(Temp_eff_bp)
            [x_w_tmp,x_T_tmp,x_losses_tmp]=...
            autoblkstabulatedlosssdata(params.w_eff_bp,params.T_eff_bp,efficiency_table_3d(:,:,i));
            NDStr=[NDStr,mat2str(x_losses_tmp),','];
        end

        NDStr(end)=')';

        set_param(Block,'x_w_eff_vec',mat2str(x_w_tmp));
        set_param(Block,'x_T_eff_vec',mat2str(x_T_tmp));
        set_param(Block,'x_tmp_eff_vec',mat2str(Temp_eff_bp));
        set_param(Block,'x_losses_mat_3d',NDStr);

    end
end



function BlockTasks=CalMapsButtonCallback(Block)

    switch get_param(Block,'param_loss')

    case 'Tabulated loss data'
        MbcLossTasks=CalLossMapsButtonCallback(Block);
    case 'Tabulated loss data with temperature'
        MbcLossTasks=CalLossWithTempMapsButtonCallback(Block);
    end

    BlockTasks=autoblksCalBlkGroupTask(Block,MbcLossTasks);
    autoblksCalApp(Block,BlockTasks,'autosharedhelp(''motor_mapped_mbc_calibration'')');
end


function MappedMotorBlkCal=CalLossMapsButtonCallback(Block)


    TestPlan=autoblksMbcSetupTestplan('MappedMotor-Loss',autoblkssharedFullMbcTemplateName('MappedMotor-Loss.mbt'));
    TestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpLossData'));
    ImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:MotPwrLossImpDesc'));
    SignalDescription={'MtrSpd',getString(message('autoblks_shared:autoblkSharedMisc:MotSpd'));...
    'MtrTrq',getString(message('autoblks_shared:autoblkSharedMisc:MotTrq'));...
    'PwrLoss',getString(message('autoblks_shared:autoblkSharedMisc:PwrLoss'))};

    TestPlan.DatasetObj.ImportDescription=ImportDescription;
    TestPlan.DatasetObj.AddSignalDescription(SignalDescription);

    MappedMtrMbcProject=autoblksMbcSetupProject;
    MappedMtrMbcProject.TestPlans=TestPlan;


    MappedMtrCageProj=autoblksCageSetupProject;
    MappedMtrCageProj.TemplateFile=autoblkssharedFullMbcTemplateName('MappedMotor-Loss.cag');
    MappedMtrCageProj.AddBpts('w_eff_bp',{@()TestPlan.MdlBndryRange('MtrSpd')})
    MappedMtrCageProj.AddBpts('T_eff_bp',{@()TestPlan.MdlBndryRange('MtrTrq')})
    MappedMtrCageProj.MbcProject=MappedMtrMbcProject;


    MappedMtrDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksshared',filesep,'mbctemplates'];


    MappedMotorBlkCal=autoblksCalSimulinkBlkMbcTask(Block,'CalLossMapData',MappedMtrMbcProject,MappedMtrCageProj,MappedMtrDataDir);
    MappedMotorBlkCal.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calMotLossMaps'));

end


function MappedMotorBlkCal=CalLossWithTempMapsButtonCallback(Block)


    TestPlan=autoblksMbcSetupTestplan('MappedMotor-LossWithTemp',autoblkssharedFullMbcTemplateName('MappedMotor-LossWithTemp.mbt'));
    TestPlan.DatasetObj.ImportName=getString(message('autoblks_shared:autoblkSharedMisc:ImpLossData'));
    ImportDescription=getString(message('autoblks_shared:autoblkSharedMisc:MotPwrLossImpDesc'));
    SignalDescription={'MtrSpd',getString(message('autoblks_shared:autoblkSharedMisc:MotSpd'));...
    'MtrTrq',getString(message('autoblks_shared:autoblkSharedMisc:MotTrq'));...
    'PwrLoss',getString(message('autoblks_shared:autoblkSharedMisc:PwrLoss'));...
    'MtrTemp',getString(message('autoblks_shared:autoblkSharedMisc:MotTmp'))};

    TestPlan.DatasetObj.ImportDescription=ImportDescription;
    TestPlan.DatasetObj.AddSignalDescription(SignalDescription);

    MappedMtrMbcProject=autoblksMbcSetupProject;
    MappedMtrMbcProject.TestPlans=TestPlan;


    MappedMtrCageProj=autoblksCageSetupProject;
    MappedMtrCageProj.TemplateFile=autoblkssharedFullMbcTemplateName('MappedMotor-LossWithTemp.cag');
    MappedMtrCageProj.AddBpts('w_eff_bp',{@()TestPlan.MdlBndryRange('MtrSpd')});
    MappedMtrCageProj.AddBpts('T_eff_bp',{@()TestPlan.MdlBndryRange('MtrTrq')});
    MappedMtrCageProj.AddNdTbl('losses_table_3d_1',{'w_eff_bp','T_eff_bp','Temp_eff_bp'});
    MappedMtrCageProj.MbcProject=MappedMtrMbcProject;


    MappedMtrDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksshared',filesep,'mbctemplates'];


    MappedMotorBlkCal=autoblksCalSimulinkBlkMbcTask(Block,'CalLossWithTempMapData',MappedMtrMbcProject,MappedMtrCageProj,MappedMtrDataDir);
    MappedMotorBlkCal.TaskName=getString(message('autoblks_shared:autoblkSharedMisc:calMotLossMaps'));
end

function single_efficiency_measurement(Block,Pbase,Piron,eff_in,w_eff,T_eff)





    eff=0.01*eff_in;
    P_mech=T_eff*w_eff;
    K=-(Piron*eff-P_mech+P_mech*eff+Pbase*eff)/(T_eff^2*eff);
    if K<0
        error(getString(message('autoblks_shared:autoblksharedErrorMsg:inconsistentLoss')));
    end
    Kw=Piron/w_eff^2;

    set_param(Block,'KLossCopper',num2str(K));
    set_param(Block,'KLossIron',num2str(Kw));

end

function tabulated_torque_speed(Block,T_t,w_t)


    if w_t(1)==0
        [~,idx]=sort(-w_t);
        w_t_extended=[-w_t(idx),w_t(2:end)];
        T_t_extended=[T_t(idx),T_t(2:end)];
    elseif w_t(1)>0
        [~,idx]=sort(-w_t);
        w_t_extended=[-w_t(idx),w_t];
        T_t_extended=[T_t(idx),T_t];
    else
        T_t_extended=T_t;
        w_t_extended=w_t;
    end

    set_param(Block,'T_t_extended',mat2str(T_t_extended));
    set_param(Block,'w_t_extended',mat2str(w_t_extended));

end

