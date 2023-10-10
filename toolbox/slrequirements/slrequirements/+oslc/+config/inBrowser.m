function result=inBrowser(changeset,localconf,component,globalconf)%#ok<INUSL> 

    persistent lastReportedContext

    if nargin>0


        lastReportedContext.changeset=changeset;
        lastReportedContext.localconf=localconf;
        lastReportedContext.globalconf=globalconf;

        if rmipref('OslcMatchBrowserContext')




            if isempty(changeset)
                configUri=localconf;
            else
                configUri=changeset;
            end

            projName=oslc.Project.currentProject();
            if isempty(projName)
                rmiut.warnNoBacktrace('Slvnv:oslc:ConfigContextUpdateNoProject');
                return;
            end

            proj=oslc.Project.get(projName);
            currentConfig=proj.getContext();

            if isempty(currentConfig)||~strcmp(currentConfig.uri,configUri)
                if~isempty(globalconf)&&rmi.settings_mgr('get','oslcSettings','useGlobalConfig')
                    newConfig=oslc.matlab.DngClient.resolveGlobalConfig(globalconf);
                    if isempty(newConfig)
                        rmiut.warnNoBacktrace('Slvnv:oslc:ConfigContextUnableToResolve',globalconf,projName);
                        return;
                    end
                else
                    [newConfig,configId]=oslc.config.resolveForProject(projName,configUri);
                    if isempty(newConfig)
                        if proj.isTesting
                            newConfig=struct('name',configId,'url',configId);
                        else
                            rmiut.warnNoBacktrace('Slvnv:oslc:ConfigContextUnableToResolve',configId,projName);
                            return;
                        end
                    end
                end
                proj.setContext(newConfig.url,newConfig.name);
            end
        end

    else

    end

    result=lastReportedContext;
end

