











function[configStruct,currentProjName]=dngGetSessionConfig()


    currentProjName=oslc.Project.currentProject();
    if isempty(currentProjName)
        error(message('Slvnv:oslc:MatlabSaysProjectNotSelected'));
    end


    webContext=oslc.config.inBrowser();
    if isempty(webContext)
        error(message('Slvnv:oslc:BrowserContextNotKnown'));
    end




    isGlobalConfig=false;
    if~isempty(webContext.globalconf)&&rmi.settings_mgr('get','oslcSettings','useGlobalConfig')
        configUri=webContext.globalconf;
        isGlobalConfig=true;
    elseif isempty(webContext.changeset)
        configUri=webContext.localconf;
    else
        configUri=webContext.changeset;
    end


    if isGlobalConfig
        configStruct=oslc.matlab.DngClient.resolveGlobalConfig(configUri);
    else
        configStruct=oslc.config.resolveForProject(currentProjName,configUri);
    end
end
