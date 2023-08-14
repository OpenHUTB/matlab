function contextsData=getRecentContexts(this,isUI)
    if nargin<2
        isUI=false;
    end

    if isUI
        rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:oslc:CheckingConfigurations')));
        cl=onCleanup(@()rmiut.progressBarFcn('delete'));
    end


    connectionObj=oslc.connection();
    clientProjName=char(connectionObj.getProject());
    if isempty(clientProjName)||~strcmp(clientProjName,this.name)
        connectionObj.setProject(this.name);
    else


        connectionObj.updateContexts();
    end

    if isa(connectionObj,'oslc.matlab.DngClient')

        contextsData=[this.history.streams;this.history.changesets;this.history.baselines];

    else

        if isUI
            rmiut.progressBarFcn('set',0.3,getString(message('Slvnv:oslc:CheckingConfigurations')));
        end
        streams=oslc.getRecentContextsByType(this.name,'stream',connectionObj);
        if isUI
            rmiut.progressBarFcn('set',0.5,getString(message('Slvnv:oslc:CheckingConfigurations')));
        end
        changesets=oslc.getRecentContextsByType(this.name,'changeset',connectionObj);
        if isUI
            rmiut.progressBarFcn('set',0.7,getString(message('Slvnv:oslc:CheckingConfigurations')));
        end
        baselines=oslc.getRecentContextsByType(this.name,'baseline',connectionObj);

        contextsData=[streams;changesets;baselines];
    end
end
