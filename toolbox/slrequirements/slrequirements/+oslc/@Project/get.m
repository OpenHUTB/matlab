function proj=get(projectName,myConnection)


    proj=oslc.Project.registry(projectName);


    if~isempty(proj)&&proj.isTesting
        return;
    elseif strcmp(projectName,oslc.Project.dummyName)
        proj=oslc.Project('',oslc.Project.dummyName);
        return;
    end



    if isempty(proj)
        if nargin<2
            myConnection=oslc.connection();
        end
        proj=oslc.Project(myConnection,projectName);
        if isempty(proj)
            error(message('Slvnv:oslc:FailedToConnectWith',projectName));
        end
    else


        if nargin==2
            connectedProjName=char(myConnection.getProject());
            if isempty(connectedProjName)||~strcmp(connectedProjName,projectName)
                myConnection.setProject(projectName);
            end
        end
    end

    oslc.Project.currentProject(proj.name,proj.queryBase);
end

