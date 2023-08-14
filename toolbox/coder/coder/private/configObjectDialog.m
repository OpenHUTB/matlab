






function configObjectDialog(action,project,varargin)
    persistent projectMap;
    if isempty(projectMap)
        projectMap=containers.Map();
    end

    uuid=char(project.getUuid());

    if strcmp(action,'show')






        configObject=varargin{1};
        projectMap(uuid)=configObject;

        project.addMatlabChangeCallback('emlcprivate',...
        {'configObjectDialog','commit',project});

        javaMethodEDT(...
        'invokeTemporaryProject',...
        'com.mathworks.toolbox.coder.proj.settingsui.NewSettingsDialog',...
        project,...
        {'paramset.paths','paramset.polyspace'},...
        'com.mathworks.toolbox.coder.plugin.CommandLineSettingsPanel',...
        'emlcprivate',...
        {'configObjectDialog','destroy',project});

    elseif strcmp(action,'showHardwareDialog')



        configObject=varargin{1};
        projectMap(uuid)=configObject;

        project.addMatlabChangeCallback('emlcprivate',...
        {'configObjectDialog','commit',project});

        javaMethodEDT(...
        'invoke',...
        'com.mathworks.toolbox.coder.app.HardwareImplementationDialog',...
        project);

    elseif strcmp(action,'commit')



        if isKey(projectMap,uuid)
            configObject=projectMap(uuid);
            tryCopyProjectToConfig(project,configObject);
        end

    elseif strcmp(action,'destroy')










        cleanup=onCleanup(@()com.mathworks.project.impl.model.ProjectManager.close(project,false));
        if isKey(projectMap,uuid)
            configObject=projectMap(uuid);
            remove(projectMap,uuid);
            tryCopyProjectToConfig(project,configObject);
        end
    end
end


function tryCopyProjectToConfig(project,configObject)




    try
        copyProjectToConfigObject(project,configObject);
    catch me
        es.message=me.message;
        es.identifier=me.identifier;
        es.stack.file='';
        es.stack.name=class(configObject);
        es.stack.line=0;
        error(es);
    end
end