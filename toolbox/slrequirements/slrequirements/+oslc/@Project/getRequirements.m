function reqs=getRequirements(this,oslcConnection,isUI,doRefresh)



    oslc.Project.currentProject(this.name,this.queryBase);

    if nargin<2
        oslcConnection=oslc.connection();
    end

    if nargin<3
        isUI=false;
    end
    progressMessage=getString(message('Slvnv:oslc:GettingContentsOf',this.name));
    if isUI
        rmiut.progressBarFcn('set',0.1,progressMessage);
    else
        fprintf('%s',progressMessage);
    end

    if nargin<4
        doRefresh=false;
    end
    if doRefresh
        this.itemIds=[];
    end

    if~isempty(this.itemIds)&&this.isUpToDate(oslcConnection)

        reqs=oslc.Requirement.getCachedItems(this.itemIds);

    else

        rdf=char(oslcConnection.get(this.reqQueryCapability));
        if isUI
            rmiut.progressBarFcn('set',0.2,progressMessage);
            cl=onCleanup(@()rmiut.progressBarFcn('delete'));
        end
        requirementsURIs=this.parseRequirementsURI(rdf,isUI);
        if isempty(requirementsURIs)
            reqs=[];
            this.itemIds=[];
        elseif isUI
            progressBarInfo.text=progressMessage;
            progressBarInfo.range=[0.5,0.95];
            reqs=oslc.Requirement.getRequirements(oslcConnection,requirementsURIs,this.name,this.queryBase,progressBarInfo);
            this.itemIds=oslc.Project.cacheIDs(this.itemIds,reqs);
        else
            reqs=oslc.Requirement.getRequirements(oslcConnection,requirementsURIs,this.name,this.queryBase,true);
            this.itemIds=oslc.Project.cacheIDs(this.itemIds,reqs);
        end
    end
    if~isUI
        fprintf('\n');
    end
end
