function[varargout]=autoblkscompressor(varargin)




    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'CalMapButtonCallback'
        varargout{1}=CalMapButton(Block);

    end

end

function Initialization(Block)

    autoblkssetupengflwmassfrac(Block);



    ParamList={'R',[1,1],{'gt',200;'lt',400};...
    'cp',[1,1],{'gt',0;'lt',5000};...
    'P_ref',[1,1],{'gt',0};...
    'T_ref',[1,1],{'gt',0}};

    Breakpoints={'w_corr_bpts1',{},'Pr_bpts2',{'gt',0}};

    LookupTblList={Breakpoints,'eta_comp_tbl',{'gt',0;'lte',1};...
    Breakpoints,'mdot_corr_tbl',{'gte',0}};

    autoblkscheckparams(Block,ParamList,LookupTblList);

end


function IconInfo=DrawCommands(Block)


    AliasNames={'Inlet','A';...
    'Outlet','B';...
    'Shft','Ds'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='boost_compressor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,30,65,'white');
end


function BlockTasks=CalMapButton(Block)


    MassFlwRateTestPlan=autoblksMbcSetupTestplan('MassFlwRate',autoblksFullTemplateName('CmpsrMassFlwRate.mbt'));
    EffTestPlan=autoblksMbcSetupTestplan('Eff',autoblksFullTemplateName('CmpsrEff.mbt'));
    MassFlwRateTestPlan.ShareDatasetImport(EffTestPlan);
    MassFlwRateTestPlan.DatasetObj.ImportName=getString(message('autoblks:autoblkMbcCal:impCompData'));

    EffTestPlan.DatasetObj.ImportName=getString(message('autoblks:autoblkMbcCal:impCompData'));
    CmprsMbcProject=autoblksMbcSetupProject;
    SignalDescription={'Eff',getString(message('autoblks:autoblkMbcCal:dlgEff'));...
    'MassFlwRate',getString(message('autoblks:autoblkMbcCal:dlgMassFlwRate'));...
    'PrsRatio',getString(message('autoblks:autoblkMbcCal:dlgPrsRatio'));...
    'Spd',getString(message('autoblks:autoblkMbcCal:dlgSpd'))};
    MassFlwRateTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
    EffTestPlan.DatasetObj.AddSignalDescription(SignalDescription);
    CmprsMbcProject.TestPlans=[MassFlwRateTestPlan,EffTestPlan];


    CmprsCageProj=autoblksCageSetupProject(autoblksFullTemplateName('CmpsrCageTemplate.cag'));
    CmprsCageProj.AddBpts('w_corr_bpts1',{0,@()MassFlwRateTestPlan.DatasetObj.DataUpperBndry('Spd')});
    CmprsCageProj.AddBpts('Pr_bpts2',{0.5,@()MassFlwRateTestPlan.DatasetObj.DataUpperBndry('PrsRatio')});
    CmprsCageProj.MbcProject=CmprsMbcProject;


    CmprsDataDir=[matlabroot,filesep,'toolbox',filesep,'autoblks',filesep,'autoblksutilities',filesep,'mbctemplates'];


    CmprsBlkCalTask=autoblksCalSimulinkBlkMbcTask(Block,'CalCmprsData',CmprsMbcProject,CmprsCageProj,CmprsDataDir);
    CmprsBlkCalTask.TaskName=getString(message('autoblks:autoblkMbcCal:calCompMaps'));
    BlockTasks=autoblksCalBlkGroupTask(Block,CmprsBlkCalTask);
    autoblksCalApp(Block,BlockTasks,'autoblkshelp(''compressor_mbc_calibration'')');

end