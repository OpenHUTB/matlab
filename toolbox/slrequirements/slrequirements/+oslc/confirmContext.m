function ok=confirmContext(projName)

    wantedConfig=slreq.dngGetSessionConfig();
    if isempty(wantedConfig)
        ok=true;
        return;
    end
    proj=oslc.Project.get(projName);
    currentContext=proj.getContext();
    if isempty(currentContext.uri)


        proj.setContext(wantedConfig.url,wantedConfig.name);
        ok=true;
    elseif strcmp(currentContext.uri,wantedConfig.url)
        ok=true;
    elseif rmipref('OslcMatchBrowserContext')

        proj.setContext(newConfig.url,newConfig.name);
        ok=true;
    else
        ok=oslc.config.confirmUpdate(projName,wantedConfig);
    end
end
