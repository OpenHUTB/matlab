

classdef Project<handle








    properties(SetAccess=private)
name
url
queryBase
reqQueryCapability
collectionQueryCapability
detailsURI
title
summary
modified

itemIds
collectionIds
contentsList
context
history
isTesting
usingModules
confirmingConfig
    end

    properties(Constant,Hidden)
        dummyName='SLREQ_DUMMY_PROJECT';
    end



    methods(Access='private')


        function proj=Project(oslcConnection,projectName)
            proj.name=projectName;
            proj.usingModules=true;
            proj.confirmingConfig=true;
            if ischar(oslcConnection)&&strcmp(projectName,oslc.Project.dummyName)

                proj.isTesting=true;
                proj.url='https://DUMMY.PROJECT.URL';
                proj.queryBase='https://DUMMY.QUERY.BASE';
                proj.context.uri='DUMMY_CONTEXT_URI';
                proj.context.name='DUMMY_CONTEXT_NAME';

                oslc.Project.registry(proj);
                oslc.Project.currentProject(proj.name,proj.queryBase);
            else
                proj.isTesting=false;
                proj.url=char(oslcConnection.setProject(projectName));
                if isempty(proj.url)


                    return;
                end
                projectRDF=char(oslcConnection.get(proj.url));
                proj.queryBase=oslc.Project.getQueryBase(projectRDF);
                proj.detailsURI=oslc.parseValue(projectRDF,'oslc:details rdf:resource=');
                detailsRDF=char(oslcConnection.get(proj.detailsURI));
                proj.title=oslc.getTitle(detailsRDF,'dcterms');
                proj.summary=oslc.parseValue(detailsRDF,'process:summary');
                proj.reqQueryCapability=char(oslcConnection.getReqQueryCapability());
                proj.collectionQueryCapability=char(oslcConnection.getCollectionQueryCapability());

                proj.modified=oslc.parseValue(detailsRDF,'dcterms:modified');
                proj.itemIds=[];
                oslc.Project.registry(proj);

                proj.collectionIds={};
                proj.contentsList.labels={};
                proj.contentsList.depths=[];
                proj.contentsList.locations={};
                proj.contentsList.currentId=[];
                proj.contentsList.isUpdated=false;

                proj.context.uri='';
                proj.context.name='';
            end
        end

        function refreshCollectionsList(this)












            [types,names,ids]=oslc.matlab.CollectionsMgr.getInstance.getTypesAndNames(this.name);
            locations=ids;
            labels=strcat(types,names);
            depths=zeros(size(locations));



            [sortedLabels,sortIdx]=sort(labels);
            this.collectionIds=locations(sortIdx);
            this.setContentsList(sortedLabels,depths,this.collectionIds);
        end

        function[labels,depths,locations]=getContentsList(this)
            labels=this.contentsList.labels;
            depths=this.contentsList.depths;
            locations=this.contentsList.locations;
        end

        function setContentsList(this,labels,depths,locations)
            this.contentsList.labels=labels;
            this.contentsList.depths=depths;
            this.contentsList.locations=locations;
        end
    end



    methods

        function ctx=getContext(this)
            ctx=this.context;
        end

        function useModules(this,value)
            this.usingModules=value;
        end

        function confirmConfig(this,value)
            this.confirmingConfig=value;
        end

        function yesno=isUpToDate(this,oslcConnection)
            lastModified=this.modified;
            newModified=this.getTime(oslcConnection);
            yesno=strcmp(newModified,lastModified);
            if~yesno
                this.itemIds=[];
            end
        end

        function modified=getTime(this,oslcConnection)
            detailsRDF=char(oslcConnection.get(this.detailsURI));
            this.modified=oslc.parseValue(detailsRDF,'dcterms:modified');
            modified=this.modified;
        end


        function[labels,depths,locations]=listAllRequirements(this,doRefresh)
            myConnection=oslc.connection();
            requirements=this.getRequirements(myConnection,true,doRefresh);
            if~isempty(requirements)
                [labels,depths,locations]=oslc.Project.listRequirements(requirements,this.name,0);
            else
                labels{1}=getString(message('Slvnv:oslc:NoReqsOrConfError'));
                locations{1}='';
                depths(1)=0;
            end
        end

        function tf=isUpdatedList(this)
            tf=this.contentsList.isUpdated;
        end

        function contextsData=getContexts(this,isUI)
            rmiut.warnNoBacktrace(['Project.getContexts() is deprecated.',newline...
            ,'Use getRecentContexts() or getAllConfigurations() instead.']);
            contextsData=this.getRecentContexts(isUI);
        end


        updateRecentContexts(this,connectionObj);
        contextsData=getRecentContexts(this,isUI)
        [streams,baselines,changesets]=getAllConfigurations(this,connectionObj)
        reqs=getRequirements(this,oslcConnection,isUI,doRefresh)
        [requirements,numericIds]=getRequirementsByURLs(this,items,progressBarInfo,myConnection)
        [labels,depths,locations]=listCollections(this,allCollectionsIds)
        setContext(this,contextUri,contextName);
        updateContentsList(this,collectionId)
    end

    methods(Static,Access='private')

        function members=getMembers(rdf)
            matches=regexp(rdf,'<rdfs:member>([\s\S]+?)</rdfs:member>','tokens');
            members=cell(size(matches));
            for i=1:length(matches)
                members{i}=matches{i}{1};
            end
        end

        function allIDs=cacheIDs(knownIDs,reqs)
            allIdStrings={reqs(:).identifier};
            newIDs=cellfun(@str2num,allIdStrings);
            allIDs=unique([knownIDs,newIDs]);
        end

        function orderedIndex=getOrderedIndex(requirements)




            allIdStrings={requirements(:).identifier};
            allIds=cellfun(@str2num,allIdStrings);
            [~,orderedIndex]=sort(allIds,'ascend');
        end


        [labels,depths,locations]=listRequirements(requirements,parentName,offset)
        reqInfo=parseRequirementsURI(rdf,isUI)
    end

    methods(Static)

        function projectNames=getProjectNames()
            rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:oslc:GettingCatalog')));
            cln=onCleanup(@()rmiut.progressBarFcn('delete'));
            myConnection=oslc.connection();
            if isempty(myConnection)
                error(message('Slvnv:oslc:FailedLoginMessage'));
            else
                catalogInfo=oslc.getCatalog(myConnection);
                projectNames=catalogInfo(:,1);
            end
        end

        function modified=getDate(projectName)
            myConnection=oslc.connection();
            if isempty(myConnection)
                modified=getString(message('Slvnv:oslc:Unavailable'));
            else
                proj=oslc.Project.get(projectName,myConnection);
                modified=proj.getTime(myConnection);
            end
        end

        function[projName,projBase]=currentProject(varargin)
            persistent currentName currentBase;
            if nargin==0
                projName=currentName;
                projBase=currentBase;
            elseif nargin==1
                projName=varargin{1};
                oslc.Project.get(projName);
                projName=currentName;
                projBase=currentBase;
            else
                currentName=varargin{1};
                currentBase=varargin{2};
            end
        end


        proj=get(projectName,myConnection)
        queryBase=getQueryBase(rdf)
        varargout=registry(proj)
    end

    methods(Static,Hidden)

        function proj=dummyProject()

            proj=oslc.Project.get(oslc.Project.dummyName);
            oslc.Project.currentProject(proj.name,proj.queryBase);
        end

    end

end


