







function setDefaultConfiguration(ConfigFilePath,varargin)
    if~contains(ConfigFilePath,filesep)
        ConfigFilePath=which(ConfigFilePath);
    end
    PrefFile=fullfile(prefdir,'mdladvprefs.mat');
    if exist(PrefFile,'file')
        load(PrefFile);%#ok<LOAD> % read current ConfigPrefs
    end
    ConfigPrefs.FilePath=ConfigFilePath;
    if exist(PrefFile,'file')
        save(PrefFile,'ConfigPrefs','-append');
    else
        save(PrefFile,'ConfigPrefs');
    end

    if nargin>1&&isa(varargin{1},'Simulink.ModelAdvisor')
        maobj=varargin{1};
        maobj.PreferenceConfigFilePath=ConfigFilePath;
        modeladvisorprivate('modeladvisorutil2','UpdateSetConfigUIMenu',maobj);
    end


    if isempty(ConfigFilePath)

        if exist(fullfile(prefdir,'edittimecheckcustomization.xml'),'file')
            delete(fullfile(prefdir,'edittimecheckcustomization.xml'));
        end
        if exist(fullfile(prefdir,'edittimecheckcustomization.json'),'file')
            delete(fullfile(prefdir,'edittimecheckcustomization.json'));
        end
        if exist(fullfile(prefdir,'blockconstraintscustomization.xml'),'file')
            delete(fullfile(prefdir,'blockconstraintscustomization.xml'));
        end

        modeladvisorprivate('modeladvisorutil2','refreshAdvisorConfigurationForEditTime');
    else
        ModelAdvisor.ConfigUI.setEditTimeCheckingBehavior(ConfigFilePath);
    end






















