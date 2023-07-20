function[varargout]=autoblksturbine(varargin)






    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'TurbTypePopupCallback'
        TurbTypePopupCallback(Block);
    case 'IncludeWgCheckCallback'
        IncludeWgCheckCallback(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'CalMapsButtonCallback'
        varargout{1}=CalMapsButtonCallback(Block);
    end

end


function Initialization(Block)

    TurbTypePopupCallback(Block)
    IncludeWgCheckCallback(Block)



    WgOptions={'autolibboostcommon/Wastegate','Wastegate';...
    'autolibboostcommon/No Wastegate','No Wastegate'};
    InportPortNum=0;
    if strcmp(get_param(Block,'WgIncludeCheckbox'),'on')
        autoblksreplaceblock(Block,WgOptions,1);
        InportPortNum=InportPortNum+1;
    else
        autoblksreplaceblock(Block,WgOptions,2);
    end


    TurbTypeInputOptions={'built-in/Ground','RackPos Ground';...
    'built-in/Inport','RackPos'};
    TurbTypeTblOptions={'autolibboostcommon/Fixed Turbine Performance Maps','Fixed Turbine Performance Maps';...
    'autolibboostcommon/Variable Turbine Performance Maps','Variable Turbine Performance Maps'};
    MapTypeParent=[Block,'/Turbine/Performance Maps'];
    switch get_param(Block,'TurbTypePopup')
    case 'Fixed geometry'
        autoblksreplaceblock(Block,TurbTypeInputOptions,1);
        autoblksreplaceblock(MapTypeParent,TurbTypeTblOptions,1);
    case 'Variable geometry'
        autoblksreplaceblock(Block,TurbTypeInputOptions,2);
        InportPortNum=InportPortNum+1;
        set_param([Block,'/RackPos'],'Port',num2str(InportPortNum));
        autoblksreplaceblock(MapTypeParent,TurbTypeTblOptions,2);
    end


    autoblkssetupengflwmassfrac(Block);


    ParamList={'R',[1,1],{'gt',200;'lt',400};...
    'cp',[1,1],{'gt',0;'lt',5000};...
    'P_ref',[1,1],{'gt',0};...
    'T_ref',[1,1],{'gt',0};...
    'mdot_thresh',[1,1],{'gt',0};...
    'A_wgopen',[1,1],{'gte',0};...
    'Plim_wg',[1,1],{'gt',0;'lt',1}};

    FixedTblBpt={'w_corrfx_bpts1',{},'Pr_fx_bpts2',{'gt',0}};
    VarTblBpt={'w_corrvr_bpts2',{},'Pr_vr_bpts2',{'gt',0},'L_rack_bpts3',{}};

    LookupTblList={FixedTblBpt,'eta_turbfx_tbl',{'gt',0;'lte',1};...
    FixedTblBpt,'mdot_corrfx_tbl',{'gte',0};...
    VarTblBpt,'eta_turbvr_tbl',{'gt',0;'lte',1};...
    VarTblBpt,'mdot_corrvr_tbl',{'gte',0}};

    autoblkscheckparams(Block,ParamList,LookupTblList);

end


function TurbTypePopupCallback(Block)
    FixedGeomParams={'mdot_corrfx_tbl','eta_turbfx_tbl','w_corrfx_bpts1','Pr_fx_bpts2'};
    VarGeomParams={'mdot_corrvr_tbl','eta_turbvr_tbl','w_corrvr_bpts2','Pr_vr_bpts2','L_rack_bpts3'};
    switch get_param(Block,'TurbTypePopup')
    case 'Fixed geometry'
        autoblksenableparameters(Block,FixedGeomParams,VarGeomParams);
    case 'Variable geometry'
        autoblksenableparameters(Block,VarGeomParams,FixedGeomParams);
    end
end


function IncludeWgCheckCallback(Block)
    if strcmp(get_param(Block,'WgIncludeCheckbox'),'on')
        autoblksenableparameters(Block,[],[],{'WgTab'},[])
    else
        autoblksenableparameters(Block,[],[],[],{'WgTab'})
    end
end



function IconInfo=DrawCommands(Block)

    AliasNames={'Inlet','A';...
    'Outlet','B';...
    'Shft','Ds'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='boost_turbine.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,30,65,'white');
end


function BlockTasks=CalMapsButtonCallback(Block)
    switch get_param(Block,'TurbTypePopup')
    case 'Fixed geometry'
        MapTasks=CalFixedMapsButtonCallback(Block);
    case 'Variable geometry'
        MapTasks=CalVariableMapsButtonCallback(Block);
    end
    BlockTasks=autoblksCalBlkGroupTask(Block,MapTasks);
    autoblksCalApp(Block,BlockTasks,'autoblkshelp(''turbine_mbc_calibration'')');

end

function FixedTurbineCalTask=CalFixedMapsButtonCallback(Block)


    FixedTurbineTestPlan=autoblksMbcSetupTestplan('FixedTurbine',autoblksFullTemplateName('FixedTurbine.mbt'));
    SignalDescription={'Eff',getString(message('autoblks:autoblkMbcCal:dlgEff'));...
    'MassFlwRate',getString(message('autoblks:autoblkMbcCal:dlgMassFlwRate'));...
    'PrsRatio',getString(message('autoblks:autoblkMbcCal:dlgPrsRatio'));...
    'Spd',getString(message('autoblks:autoblkMbcCal:dlgSpd'))};
    FixedTurbineTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
    FixedTurbineTestPlan.DatasetObj.ImportName=getString(message('autoblks:autoblkMbcCal:impTurbData'));
    FixedTurbineMbcProject=autoblksMbcSetupProject;
    FixedTurbineMbcProject.TestPlans=FixedTurbineTestPlan;


    FixedTurbineCageProj=autoblksCageSetupProject(autoblksFullTemplateName('FixedTurbineCageTemplate.cag'));
    FixedTurbineCageProj.AddBpts('w_corrfx_bpts1',{0,@()FixedTurbineTestPlan.DatasetObj.DataUpperBndry('Spd')});
    FixedTurbineCageProj.AddBpts('Pr_fx_bpts2',{1,@()FixedTurbineTestPlan.DatasetObj.DataUpperBndry('PrsRatio')});
    FixedTurbineCageProj.MbcProject=FixedTurbineMbcProject;


    FixedTurbineDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksutilities',filesep,'mbctemplates'];



    FixedTurbineCalTask=autoblksCalSimulinkBlkMbcTask(Block,'CalFixedMapsData',FixedTurbineMbcProject,FixedTurbineCageProj,FixedTurbineDataDir);
    FixedTurbineCalTask.TaskName=getString(message('autoblks:autoblkMbcCal:calTurbMaps'));
end


function VgtCalTask=CalVariableMapsButtonCallback(Block)

    VgtTestPlan=autoblksMbcSetupTestplan('Vgt-Point-by-Point',autoblksFullTemplateName('Vgt-Point-by-Point.mbt'));
    VgtTestPlan.DatasetObj.ImportName=getString(message('autoblks:autoblkMbcCal:impVarTurbData'));
    VgtMbcProject=autoblksMbcSetupProject;
    VgtMbcProject.TestPlans=VgtTestPlan;
    SignalDescription={'Eff',getString(message('autoblks:autoblkMbcCal:dlgEff'));...
    'MassFlwRate',getString(message('autoblks:autoblkMbcCal:dlgMassFlwRate'));...
    'PrsRatio',getString(message('autoblks:autoblkMbcCal:dlgPrsRatio'));...
    'Spd',getString(message('autoblks:autoblkMbcCal:dlgSpd'));...
    'RackPos',getString(message('autoblks:autoblkMbcCal:dlgRackPos'))};
    VgtTestPlan.DatasetObj.AddSignalDescription(SignalDescription);


    VgtCageProj=autoblksCageSetupProject(autoblksFullTemplateName('VgtBaseCageTemplate.cag'));
    VgtCageProj.AddBpts('w_corrvr_bpts2',{0,@()VgtTestPlan.DataUpperBndry('Spd')});
    VgtCageProj.AddBpts('Pr_vr_bpts2',{1,@()VgtTestPlan.DataUpperBndry('PrsRatio')});
    VgtCageProj.AddNdTbl('mdot_corrvr_tbl_1',{'w_corrvr_bpts2','Pr_vr_bpts2','L_rack_bpts3'});
    VgtCageProj.AddNdTbl('eta_turbvr_tbl_1',{'w_corrvr_bpts2','Pr_vr_bpts2','L_rack_bpts3'});
    VgtCageProj.MbcProject=VgtMbcProject;


    VgtDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksutilities',filesep,'mbctemplates'];


    VgtCalTask=autoblksCalSimulinkBlkMbcTask(Block,'CalVgtMapsData',VgtMbcProject,VgtCageProj,VgtDataDir);
    VgtCalTask.TaskName=getString(message('autoblks:autoblkMbcCal:calTurbMaps'));


end