function resultJSON=getModelAdvisorTreeData(maType,varargin)















    if nargin>1
        honorPreferenceConfigSetting=varargin{1};
    else
        honorPreferenceConfigSetting=true;
    end


    caller=dbstack;
    maCall=false;
    for i=1:length(caller)
        if~isempty(strfind(caller(i).file,'openConfigUIFromMAMenu'))
            maCall=true;
            break;
        end
    end
    activeMAobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;


    PreferenceConfigFileInfo=modeladvisorprivate('modeladvisorutil2','ReadConfigPrefFileInfo');
    PreferenceConfigFilePath=PreferenceConfigFileInfo.name;

    hasInValidChecks=false;
    if honorPreferenceConfigSetting&&maCall&&exist(activeMAobj.ConfigFilePath,'file')
        [jsonString,filepath]=loadFromConfigFile(activeMAobj.ConfigFilePath);
        [~,~,ext]=fileparts(filepath);
        result=ModelAdvisorWebUI.interface.checkInvalidChecks();
        hasInValidChecks=result.hasInValidChecks;
        if hasInValidChecks&&strcmp(ext,'.json')
            jsonStruct=jsondecode(jsonString);
            jsonStruct.Tree=ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.getCompletecuiCellArray;
            jsonString=jsonencode(jsonStruct);
        end

    elseif honorPreferenceConfigSetting&&exist(PreferenceConfigFilePath,'file')
        [jsonString,filepath]=loadFromConfigFile(PreferenceConfigFilePath);
    else
        am=Advisor.Manager.getInstance;
        cacheFilePath=am.getCacheFilePath;
        if strcmp(maType,'MALB_ByProduct')
            load(cacheFilePath,'MACE_RootLevelFolders');
            jsonString=MACE_RootLevelFolders{1};
        else
            load(cacheFilePath,maType);
            jsonString=eval(maType);
        end

        filepath='';
    end

    SLVersion=ver('Simulink');
    SLVersion=SLVersion.Version;

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath',filepath,'version',SLVersion,'value',jsonString,'hasInValidChecks',hasInValidChecks);
    resultJSON=jsonencode(result);
end

function[jsonString,filepath]=loadFromConfigFile(ConfigFilePath)
    [~,~,ext]=fileparts(ConfigFilePath);
    if strcmpi(ext,'.mat')
        configVar=load(ConfigFilePath);
        if isfield(configVar,'jsonString')
            jsonString=configVar.jsonString;
        else
            maObj=Simulink.ModelAdvisor;
            maObj.loadConfiguration(ConfigFilePath);
            jsonString=Advisor.Utils.exportJSON(maObj,'MACE');
        end
    else
        jsonString=fileread(ConfigFilePath);
    end
    filepath=ConfigFilePath;
end