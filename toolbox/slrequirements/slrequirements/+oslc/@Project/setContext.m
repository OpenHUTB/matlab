function setContext(this,contextUri,contextName)



    if~strcmp(this.context.uri,contextUri)
        this.context.uri=contextUri;
        this.context.name=contextName;

        contextUri=strrep(contextUri,':','%3A');
        contextUri=strrep(contextUri,'/','%2F');




        contextTagStart=strfind(this.queryBase,'vvc.configuration=');
        if isempty(contextTagStart)
            contextTagStart=strfind(this.queryBase,'oslc_config.context=');
        end


        if isempty(contextTagStart)
            if isempty(contextUri)
                return;
            else
                this.queryBase=[this.queryBase,'&oslc_config.context=',contextUri];
            end
        else
            nextAmp=strfind(this.queryBase(contextTagStart:end),'&');
            if isempty(nextAmp)
                this.queryBase=[this.queryBase(1:contextTagStart-1),'oslc_config.context=',contextUri];
            else
                tail=this.queryBase(contextTagStart+nextAmp-1:end);
                this.queryBase=[this.queryBase(1:contextTagStart-1),'oslc_config.context=',contextUri,tail];
            end
        end


        oslc.Project.currentProject(this.name,this.queryBase);

        if~this.isTesting

            connection=oslc.connection();
            if isa(connection,'oslc.matlab.DngClient')
                connection.updateQueryBase(this.queryBase);
            else
                connection.setContext(contextUri);
            end

            this.reqQueryCapability=char(connection.getReqQueryCapability());
            this.collectionQueryCapability=char(connection.getCollectionQueryCapability());
        end
    end
end

function paramName=getConfigContextParamName()
    oslcSettings=rmi.settings_mgr('get','oslcSettings');
    if oslcSettings.useGlobalConfig
        paramName='oslc_config.context';
    else
        paramName=oslcSettings.configContextParam;
    end
end

