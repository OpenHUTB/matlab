function[varargout]=autoblksexteriorpmsm(varargin)


    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'PortConfigPopup'
        PortConfigPopup(Block);
    case 'SimTypeConfigPopup'
        SimTypeConfigPopup(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'ConstantTypeSelection'
        UpdateConstantType(Block);
    case 'UpdateLdq'
        UpdateLdq(Block);
    case 'FilePathBrowse'
        BrowseFilePath(Block);
    case 'LoadingParameter'
        LoadParameterFromFile(Block);
    case 'SavingParameter'
        SaveParameterToFile(Block);
    end
end

function Initialization(Block)
    PmsmOptions=...
    {'autolibpmsmcommon/PMSM Speed Input Exterior Continuous','PMSM Speed Input Exterior Continuous';
    'autolibpmsmcommon/PMSM Torque Input Exterior Continuous','PMSM Torque Input Exterior Continuous';
    'autolibpmsmcommon/PMSM Speed Input Exterior Discrete','PMSM Speed Input Exterior Discrete';
    'autolibpmsmcommon/PMSM Torque Input Exterior Discrete','PMSM Torque Input Exterior Discrete';
    };

    port_config=get_param(Block,'port_config');
    sim_type=get_param(Block,'sim_type');

    if isequal(sim_type,'Continuous')&&isequal(port_config,'Torque')
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksenabletext(Block,{'omega_initUnit','mechanicalUnit'},[]);
        autoblksreplaceblock(Block,PmsmOptions,2);
    elseif isequal(sim_type,'Continuous')&&isequal(port_config,'Speed')
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksenabletext(Block,[],{'omega_initUnit','mechanicalUnit'});
        autoblksreplaceblock(Block,PmsmOptions,1);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Torque')
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksenabletext(Block,{'omega_initUnit','mechanicalUnit'},[]);
        autoblksreplaceblock(Block,PmsmOptions,4);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Speed')
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksenabletext(Block,[],{'omega_initUnit','mechanicalUnit'});
        autoblksreplaceblock(Block,PmsmOptions,3);
    else
        error(getString(message('autoblks_shared:autoblksharedErrorMsg:blkSettingExtPMSM')));
    end


    EnableParamImportExportFeature(Block);


    ParamList={'Rs',[1,1],{'gt',0};...
    'P',[1,1],{'gt',0;'int',0;};...
    'Ldq_',[1,1],{'gt',0};...
    'idq0',[1,2],{};...
    'theta_init',[1,1],{};...
    'omega_init',[1,1],{};...
    'mechanical',[1,3],{'gte',0};...
    'Ts',[1,1],{'gt',0};...
    };
    autoblkscheckparams(Block,'Exterior',ParamList);
    ComputeKConstant(Block);
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='electric_machine_exterior_pmsm.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,200,'white');

end

function PortConfigPopup(Block)
    port_config=get_param(Block,'port_config');


    switch port_config
    case 'Torque'
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksenabletext(Block,{'omega_initUnit','mechanicalUnit','mechanicalText','omega_initText'},[]);
    case 'Speed'
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksenabletext(Block,[],{'omega_initUnit','mechanicalUnit','mechanicalText','omega_initText'});
    end


    EnableParamImportExportFeature(Block);
end

function SimTypeConfigPopup(Block)
    sim_type=get_param(Block,'sim_type');


    switch sim_type
    case 'Continuous'
        autoblksenableparameters(Block,[],{'Ts'},[],[]);
        autoblksenabletext(Block,[],{'TsUnit','TsText'});
    case 'Discrete'
        autoblksenableparameters(Block,{'Ts'},[],[],[]);
        autoblksenabletext(Block,{'TsUnit','TsText'},[]);
    end
end

function EnableParamImportExportFeature(Block)
    enImportExportFeature=get_param(Block,'aMode');
    MaskObject=get_param(gcb,'MaskObject');
    Obj=MaskObject.getDialogControl('ParamGroup');
    if strcmp(enImportExportFeature,'5')
        autoblksenableparameters(Block,{'FilePath'},[],[],[]);
        Obj.setVisible('on');
    else
        autoblksenableparameters(Block,[],{'FilePath'},[],[]);
        Obj.setVisible('off');
    end
end

function UpdateConstantType(Block)
    const_type=get_param(Block,'KConstText');
    MaskObject=get_param(Block,'MaskObject');
    Obj=MaskObject.getDialogControl('KConstUnit');

    switch const_type
    case 'Permanent flux linkage constant (lambda_pm):'
        autoblksenableparameters(Block,{'lambda_pm'},{'Ke','Kt'},[],[]);
        Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkPrm_lambda_pmUnit';
    case 'Back-emf constant (Ke):'
        autoblksenableparameters(Block,{'Ke'},{'lambda_pm','Kt'},[],[]);
        Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkPrm_KeUnit';
    case 'Torque constant (Kt):'
        autoblksenableparameters(Block,{'Kt'},{'lambda_pm','Ke'},[],[]);
        Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkPrm_KtUnit';
    end
end

function ComputeKConstant(Block)
    const_type=get_param(Block,'KConstText');

    switch const_type
    case 'Permanent flux linkage constant (lambda_pm):'
        ParamList={'lambda_pm',[1,1],{'gt',0};};
        autoblkscheckparams(Block,'Exterior',ParamList);
        lambda_pm_str=get_param(Block,'lambda_pm');
        set_param(Block,'lambda_pm_calc',lambda_pm_str);
        set_param(Block,'KConst',lambda_pm_str);
    case 'Back-emf constant (Ke):'
        ParamList={'Ke',[1,1],{'gt',0};};
        autoblkscheckparams(Block,'Exterior',ParamList);
        Ke_str=get_param(Block,'Ke');
        set_param(gcb,'Ke',Ke_str);
        Ke_val=slResolve(get_param(Block,'Ke'),Block);
        PVal=slResolve(get_param(Block,'P'),Block);
        if(~isempty(Ke_val)&&...
            ~isempty(PVal))
            lambda_pm_calc=((Ke_val/PVal)*...
            (60/(2*pi()))*(1/sqrt(3))*(1/1000));
            set_param(Block,'lambda_pm_calc',num2str(lambda_pm_calc));
        end
    case 'Torque constant (Kt):'
        ParamList={'Kt',[1,1],{'gt',0};};
        autoblkscheckparams(Block,'Exterior',ParamList);
        Kt_str=get_param(Block,'Kt');
        set_param(gcb,'KConst',Kt_str);
        Kt_val=slResolve(get_param(Block,'Kt'),Block);
        PVal=slResolve(get_param(Block,'P'),Block);
        if(~isempty(Kt_val)&&...
            ~isempty(PVal))
            lambda_pm_calc=(2/3)*(Kt_val/PVal);
            set_param(Block,'lambda_pm_calc',num2str(lambda_pm_calc));
        end
    end
end

function UpdateLdq(Block)
    ParamList={'Ldq_',[1,1],{'gt',0};};
    ParamStruct=autoblkscheckparams(Block,'Exterior',ParamList);
    Ldq=ParamStruct.Ldq_;
    set_param(Block,'Ldq',['[',num2str([Ldq,Ldq]),']']);
end


function BrowseFilePath(Block)
    FullFilePath=get_param(Block,'FilePath');


    if isempty(FullFilePath)
        defaultPath=[matlabroot,'\toolbox\autoblks\autoblksshared\mcbtemplates'];
        [file,path]=uigetfile(fullfile(defaultPath,'*.m;*.mat'));
    else
        fileFullName=get_param(Block,'FilePath');
        fileFullName=strtrim(fileFullName);
        [filePath,~,~]=fileparts(fileFullName);

        if exist(filePath,'dir')
            [file,path]=uigetfile(fullfile(filePath,'*.m;*.mat'));
        else
            [file,path]=uigetfile('*.m;*.mat');
        end
    end

    if(ischar(file)&&ischar(path))
        set_param(Block,'Filepath',strcat(path,file));
        MaskObject=get_param(Block,'MaskObject');
        Obj=MaskObject.getDialogControl('fileStatus');
        Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkinitFileStatus';
    elseif(file==0&&path==0)



    end
end


function LoadParameterFromFile(Block)
    autoblksloadparameter(Block);
end


function SaveParameterToFile(Block)
    autoblkssaveparameter(Block);
end
