function url=getNavURL(queryBase,artifactURL,contextUri)










    if nargin<3
        contextUri='';
    end

    queryBase=strtok(queryBase);

    if nargin==1||isempty(artifactURL)

        serverURL=getBaseURL(queryBase);
        if isempty(serverURL)
            error('Invalid queryBase URL: %s',queryBase);
        end
        projectURL=getProjectURL(queryBase);


        url=sprintf('%s/%s/web#action=com.ibm.rdm.web.pages.showProjectDashboard&componentURI=%s',...
        serverURL,rmipref('OslcServerRMRoot'),projectURL);
    else

        artifactURL=strtok(artifactURL);








        if contains(artifactURL,':443/')
            oslcSettings=rmi.settings_mgr('get','oslcSettings');
            if isfield(oslcSettings,'stripDefaultPortNumber')
                if oslcSettings.stripDefaultPortNumber
                    artifactURL=strrep(artifactURL,':443/','/');
                end
            end
        end


        url=artifactURL;
        if isempty(contextUri)
            contextUri=getContext(queryBase);
        end
        if~isempty(contextUri)
            url=[url,'?oslc_config.context=',contextUri];
        end
    end
end

function server=getBaseURL(queryBase)
    match=regexp(queryBase,'^(https://[^/]+)/','tokens');
    if isempty(match)
        server='';
    else
        server=match{1}{1};
    end
end

function project=getProjectURL(queryBase)
    project=getValue(queryBase,'projectURL');
end

function[context,tag]=getContext(queryBase)
    context=getValue(queryBase,'vvc.configuration');
    if~isempty(context)
        tag='vvc.configuration';
    else
        context=getValue(queryBase,'oslc_config.context');
        tag='oslc_config.context';
    end
end

function value=getValue(webargs,tag)
    match=regexp(webargs,[tag,'=([^&]+)'],'tokens');
    if isempty(match)
        value='';
    else
        value=match{1}{1};
    end
end

