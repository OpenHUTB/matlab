function[varargout]=autoblksim(varargin)


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
    case 'FilePathBrowse'
        BrowseFilePath(Block);
    case 'LoadingParameter'
        LoadParameterFromFile(Block);
    case 'SavingParameter'
        SaveParameterToFile(Block);
    end
end

function Initialization(Block)
    ImOptions=...
    {'autolibimcommon/IM Speed Input Continuous','IM Speed Input Continuous';
    'autolibimcommon/IM Torque Input Continuous','IM Torque Input Continuous';
    'autolibimcommon/IM Speed Input Discrete','IM Speed Input Discrete';
    'autolibimcommon/IM Torque Input Discrete','IM Torque Input Discrete';
    };


    port_config=get_param(Block,'port_config');
    sim_type=get_param(Block,'sim_type');

    if isequal(sim_type,'Continuous')&&isequal(port_config,'Torque')
        autoblksenableparameters(Block,{'omega_init','mechanical'},{'Ts'},[],[]);
        autoblksenabletext(Block,{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit'},{'Ts_Text'});
        autoblksreplaceblock(Block,ImOptions,2);
    elseif isequal(sim_type,'Continuous')&&isequal(port_config,'Speed')
        autoblksenableparameters(Block,[],{'omega_init','mechanical','Ts'},[],[]);
        autoblksenabletext(Block,[],{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit'});
        autoblksreplaceblock(Block,ImOptions,1);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Torque')
        autoblksenableparameters(Block,{'omega_init','mechanical','Ts'},[],[],[]);
        autoblksenabletext(Block,{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit','Ts_Text'},[]);
        autoblksreplaceblock(Block,ImOptions,4);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Speed')
        autoblksenableparameters(Block,{'Ts'},{'omega_init','mechanical'},[],[]);
        autoblksenabletext(Block,{'Ts_Text'},{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit'},[],[]);
        autoblksreplaceblock(Block,ImOptions,3);
    else
        error(getString(message('autoblks_shared:autoblksharedErrorMsg:blkSettingIM')));
    end


    EnableParamImportExportFeature(Block);


    ParamList={'Zs',[1,2],{'gt',0};...
    'Zr',[1,2],{'gt',0};...
    'Lm',[1,1],{'gt',0};...
    'P',[1,1],{'gt',0;'int',0;};...
    'theta_init',[1,1],{};...
    'omega_init',[1,1],{};...
    'mechanical',[1,3],{'gte',0};...
    'Ts',[1,1],{'gt',0};...
    };

    autoblkscheckparams(Block,'Induction Machine',ParamList);
end

function IconInfo=DrawCommands(BlkHdl)


    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);



    IconInfo.ImageName='electric_machine_induction_motor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,200,'white');
end

function PortConfigPopup(Block)
    port_config=get_param(Block,'port_config');


    switch port_config
    case 'Torque'
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksenabletext(Block,{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit'},[]);
    case 'Speed'
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksenabletext(Block,[],{'omega_init_Text','omega_init_Unit','mechanical_Text','mechanical_Unit'});
    end

    EnableParamImportExportFeature(Block);
end

function SimTypeConfigPopup(Block)
    sim_type=get_param(Block,'sim_type');


    switch sim_type
    case 'Continuous'
        autoblksenableparameters(Block,[],{'Ts'},[],[]);
        autoblksenabletext(Block,[],{'Ts_Text'});
    case 'Discrete'
        autoblksenableparameters(Block,{'Ts'},[],[],[]);
        autoblksenabletext(Block,{'Ts_Text'},[]);
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