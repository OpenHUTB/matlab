function[req,projName]=getReqItem(id,projName,isSelectionLinking,dngClient)



    if nargin<2
        projName='';
    end

    if nargin<3
        isSelectionLinking=false;
    end

    if id==0

        req='TESTING';
        return;
    end


    proj=[];
    req=oslc.Requirement.registry(id);
    if~isempty(req)
        if isempty(projName)
            projName=req.projectName;
        end



        proj=oslc.Project.get(projName);
        if~strcmp(req.queryBase,proj.queryBase)

            req.updateQueryBase(proj.queryBase);
            oslc.Requirement.registry(req);
        end
        return;
    else
        if reqmgt('rmiFeature','DngModuleSelector')
            if isSelectionLinking
                currentProjName=oslc.Project.currentProject();
                if~isempty(currentProjName)
                    proj=oslc.Project.get(currentProjName);
                end
                if isempty(proj)||proj.usingModules


                    req='RELAY';
                    return;
                end
            end
        end
    end




    if nargin<4
        dngClient=oslc.connection();
        if isempty(dngClient)
            error('Failed to acquire OSLC server connection');
        end
    end
    [req,projName]=getItemById(dngClient,id,projName);
end

function[req,projName]=getItemById(myConnection,id,projName)

    req=[];

    if isempty(projName)

        projName=oslc.Project.currentProject();
    end

    if isempty(projName)

        req=searchAllCatalogs(myConnection,id);
        return;
    end


    connectedProjName=char(myConnection.getProject());
    if isempty(connectedProjName)||~strcmp(connectedProjName,projName)
        myConnection.setProject(projName);
    end

    stringId=num2str(id);


    resourceRDF=char(myConnection.getItemRdfById(stringId));
    if~isempty(resourceRDF)
        reqData=oslc.Requirement.parseReqData(resourceRDF);
    else

        resourceURL=char(myConnection.getItemUrlById(stringId));
        if isempty(resourceURL)
            return;
        else

            reqData=oslc.Requirement.parseReqData(resourceURL,myConnection);

            if isempty(reqData)


                reqData.resource=resourceURL;
                reqData.identifier=num2str(id);


                [selectedId,selectedLabel]=oslc.selection();
                if length(selectedId)==1&&selectedId==id
                    reqData.title=selectedLabel;
                else

                    reqData.title=getString(message('Slvnv:oslc:ItemInProject',stringId,projName));
                end
            end
        end
    end
    oslc.Requirement.register(reqData,projName);
    req=oslc.Requirement.registry(reqData.identifier);
end

function req=searchAllCatalogs(myConnection,id)


    persistent catalogs;

    req=[];


    currentProject=oslc.Project.currentProject();
    if~isempty(currentProject)
        req=getItemById(myConnection,id,currentProject);
        if~isempty(req)
            return;
        end
    end

    rmiut.progressBarFcn('set',0,...
    getString(message('Slvnv:oslc:GettingCatalog')),...
    getString(message('Slvnv:oslc:PleaseWait')));
    catalogInfo=oslc.getCatalog(myConnection);
    catalogNames=catalogInfo(:,1);
    catalogDates=whenModified(catalogInfo(:,3));
    [~,idx]=sort(catalogDates);
    catalogs=catalogNames(idx);
    totalProjects=length(catalogs);
    for i=totalProjects:-1:1
        if rmiut.progressBarFcn('isCanceled')
            break;
        end
        projName=catalogs{i};
        if strcmp(projName,currentProject)
            continue;
        end
        progressValue=(totalProjects-i+0.5)/totalProjects;
        progressMessage=getString(message('Slvnv:oslc:ProcessingProject',projName));
        rmiut.progressBarFcn('set',progressValue,progressMessage);

        project=oslc.Project.get(projName,myConnection);
        if isempty(project.url)
            continue;
        end

        resourceURL=char(myConnection.getItemUrlById(num2str(id)));
        if~isempty(resourceURL)
            reqData=oslc.Requirement.parseReqData(resourceURL,myConnection);
            oslc.Requirement.register(reqData,projName,project.queryBase);
            req=oslc.Requirement.registry(reqData.identifier);
            break;
        end
    end
    rmiut.progressBarFcn('delete');

    function result=whenModified(catalogURIs)
        result=cell(size(catalogURIs));
        for n=1:length(catalogURIs)
            rdf=myConnection.get(catalogURIs{n});
            result{n}=oslc.parseValue(char(rdf),'dcterms:modified');
        end
    end

end





















