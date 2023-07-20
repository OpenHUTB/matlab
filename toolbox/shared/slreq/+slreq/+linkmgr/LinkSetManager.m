classdef LinkSetManager<handle







    properties(Hidden)
        pendingBannerMessage;
        lastBannerView;


        reqDataChangeListener;

        currentProject;

        lsmHandler=[];

        isFirstTimePathScanDone;

        pendingProjectFilesToSaveMetadata;
        pendingPathFilesToSaveMetadata;

        doLoadIncomingLinks;
        closeLinkSetsOnProjectClose;
    end

    properties(Hidden,Constant)
        ARTIFACT_PROP_SEPARATOR='::';
        ARTIFACT_NAME_COLUMN=1;
        ARTIFACT_DOMAIN_COLUMN=2;
        ARTIFACT_PATH_COLUMN=3;
        ARTIFACT_SELF_REF_TAG='_SELF';

        METADATA_SCAN_INIT_MODE_UI='ui';
        METADATA_SCAN_INIT_MODE_API='api';
        MODE_PROJECT='project';
        MODE_MLPATH='path';

        NO_CREATE_METADATA_IN_SLMX=false;
        NO_UPDATE_VIEW_FOR_BANNER=false;


        LSMH_MODE_PROJECT="PROJECT_PATH";
        LSMH_MODE_MATLAB="MATLAB_PATH";
        LSMH_MODE_DIR="DIRECTORY";
        LSMH_MODE_FILE="FILE";
        LSMH_NO_EXTENT={};
        LSMH_EVENT_SCAN_FINISHED="ScanFinished";


        REQ_META_ROOT_NODE="LinkSetMetadata"
        OUTGOING_LINKDATA_NODE="OutGoingLinkDestinations";
        ARTIFACT_DATA_NODE="Artifact";
        ARTIFACT_NAME_ATTRIBUTE="name";
        ARTIFACT_DOMAIN_ATTRIBUTE="domain";
    end

    methods(Access=private)
        function this=LinkSetManager()


            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Construct an instance of linkSetManager",'I');


            reqData=slreq.data.ReqData.getInstance;
            this.reqDataChangeListener=reqData.addlistener('ReqDataChange',@(~,eventData)this.onReqSetLoad(eventData));

            this.init();
        end

        function init(this)

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Initializing properties",'I');
            this.pendingBannerMessage=[];
            this.lastBannerView=[];
            this.currentProject=[];

            this.isFirstTimePathScanDone=false;

            this.pendingProjectFilesToSaveMetadata={};
            this.pendingPathFilesToSaveMetadata={};

            this.doLoadIncomingLinks=true;
            this.closeLinkSetsOnProjectClose=true;

            this.lsmHandler=slreq.linkmgr.LSMHandler(slreq.cpputils.getLinkMgrModel());
            this.lsmHandler.init();
        end
    end

    methods
        function delete(this)

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Deleting all the listeners",'I');
            if~isempty(this.reqDataChangeListener)
                this.reqDataChangeListener.delete();
                this.reqDataChangeListener=[];
            end

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Deleting lsmhandler object",'I');
            if~isempty(this.lsmHandler)
                this.lsmHandler.delete();
                this.lsmHandler=[];
            end

            this.reset();
        end

        function reset(this)
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Deleting lsmhandler object",'I');
            if~isempty(this.lsmHandler)
                this.lsmHandler.delete();
                this.lsmHandler=[];
            end

            this.init();



        end
    end

    methods(Static)
        function singleton=getInstance(doInit)
            mlock;
            persistent linksetManager;
            if isempty(linksetManager)||~isvalid(linksetManager)
                if nargin==0||doInit
                    linksetManager=slreq.linkmgr.LinkSetManager;
                end
            end
            singleton=linksetManager;
        end

        function tf=exists()
            instance=slreq.linkmgr.LinkSetManager.getInstance(false);
            tf=~isempty(instance);
        end
    end
    methods

        function loadIncomingLinkSetsFor(this,targetFullFilePath)


            if~this.doLoadIncomingLinks
                return;
            end
            linkSetFiles=this.findIncomingLinksetsToLoadFor(targetFullFilePath);
            if~isempty(linkSetFiles)
                reqData=slreq.data.ReqData.getInstance();
                mapper=rmimap.StorageMapper.getInstance();



                for i=1:length(linkSetFiles)
                    thisResultFile=linkSetFiles{i};
                    if isfile(thisResultFile)


                        sources=mapper.getSourceFor(thisResultFile);
                        if~isempty(sources)
                            artifactName=sources{1};
                        else



                            artifactName=slreq.uri.getShortNameExt(thisResultFile);
                        end

                        try
                            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Loading the linkset "+linkSetFiles(i),'G');
                            reqData.loadLinkSet(artifactName,thisResultFile,targetFullFilePath);
                        catch ex
                            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Invalid or corrupted SLMX file "+thisResultFile,'W');
                            if strcmp(ex.identifier,'Slvnv:slreq_uri:LinksForNameAlreadyLoadedFrom')





                            else
                                rethrow(ex);
                            end
                        end
                    end
                end
            end
        end

        function reIndexMetadata(this,doCreateMetadata)
            if nargin<2


                doCreateMetadata=true;
            end
            if this.isSimulinkProjectOpen
                this.reIndexProjectMetadata(doCreateMetadata);
            else
                this.reIndexNonProjectMetadata(doCreateMetadata);
            end
        end

        function scanMATLABPathOnSlreqInit(this,mode)







            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Editor or requirement perspective is opened",'I');
            if this.isFirstTimePathScanDone||this.isSimulinkProjectOpen
                return;
            end
            this.isFirstTimePathScanDone=true;
            switch mode
            case this.METADATA_SCAN_INIT_MODE_UI
                this.lsmHandler.scanAsync(this.LSMH_MODE_MATLAB,this.LSMH_NO_EXTENT);
            case this.METADATA_SCAN_INIT_MODE_API
                this.lsmHandler.scanSync(this.LSMH_MODE_MATLAB,this.LSMH_NO_EXTENT);

            end
        end
    end

    methods(Hidden)
        function linkSetFiles=findIncomingLinksetsToLoadFor(this,artifactFullFilePath)

            [~,artifactName,fExt]=fileparts(artifactFullFilePath);
            artifactDomain=slreq.utils.getDomainLabel(artifactFullFilePath);

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Loading Linksets for "+artifactName+" requirement set",'I');
            linkSetFiles=this.lsmHandler.findIncomingLinksets(artifactName,artifactDomain);
            if strcmpi(fExt,'.slx')



                linkSetFiles=[linkSetFiles,this.lsmHandler.findIncomingLinksets(artifactName,'linktype_rmi_slreq')];
            end
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Got "+numel(linkSetFiles)+" linksets",'G');
        end



        function scanProject(this)
            files=slreq.linkmgr.LinkSetManager.getProjectFiles();
            this.lsmHandler.scanAsync(this.LSMH_MODE_PROJECT,files);
        end

        function scanMATLABPath(this)
            this.lsmHandler.scanAsync(this.LSMH_MODE_MATLAB,this.LSMH_NO_EXTENT);
        end

        function reIndexProjectMetadata(this,createMetadata)
            if~this.isSimulinkProjectOpen
                return;
            end





            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Scanning the current project again for explicitly reindexing project metadata",'I');
            this.lsmHandler.scanSync(this.LSMH_MODE_PROJECT,this.getProjectFiles());


            if createMetadata
                slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Building metadata for pending files",'I');
                this.updateMetadataForPendingFiles();
            end
        end

        function reIndexNonProjectMetadata(this,createMetadata)





            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Scanning the current project again for explicitly reindexing non-project metadata",'I');
            this.lsmHandler.scanSync(this.LSMH_MODE_MATLAB,this.LSMH_NO_EXTENT);


            if createMetadata
                slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Building metadata for pending files",'I');
                this.updateMetadataForPendingFiles();
            end
        end

        function updateMetadataForPendingFiles(this)
            if this.isSimulinkProjectOpen
                this.buildMetadataForLinkSetFiles(this.pendingProjectFilesToSaveMetadata);
                this.pendingProjectFilesToSaveMetadata={};
            else
                this.buildMetadataForLinkSetFiles(this.pendingPathFilesToSaveMetadata);
                this.pendingPathFilesToSaveMetadata={};
            end

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Clearing any existing banner messages",'I');
            this.clearPendingBannerMessage(true);
        end

        function clearNonProjectMetadataCache(this)
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","clearing the in-memory cache",'I');
            this.lsmHandler.clearMATLABCache();
        end


        function buildMetadataForLinkSetFiles(this,linkSetFiles)

            for i=1:length(linkSetFiles)

                this.buildMetadataForLinksetFile(linkSetFiles{i});
            end
        end

        function buildMetadataForLinksetFile(this,linkSetFullFilePath)

            if~isfile(linkSetFullFilePath)
                return;
            end
            reqData=slreq.data.ReqData.getInstance();
            mfLinkSet=[];
            try
                mfLinkSet=reqData.loadLinkSetRaw(linkSetFullFilePath);


                slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","building metadata for  "+linkSetFullFilePath,'G');
                this.updateMetadataFromLinkset(mfLinkSet,linkSetFullFilePath);
            catch ex %#ok<NASGU>
            end

            if~isempty(mfLinkSet)
                mfLinkSet.destroy();
            end
        end

        function updateMetadataFromLinkset(this,mfLinkSet,linkSetFullFilePath)

            destinationArtifacts=this.getLinkDestinations(mfLinkSet);


            this.updateMetadata(linkSetFullFilePath,destinationArtifacts(:,1:2));
        end

        function updateMetadata(this,slmxfile,destinationArtifacts)


            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","writing SLMX "+string(slmxfile)+"Metadata using Xerces API",'G');
            this.writeSLMXMetadata(slmxfile,destinationArtifacts);
        end

        function registerOpenArtifactsForLinkSet(this,dataLinkSet)
            artifactTable=this.getLinkDestinations(dataLinkSet);
            this.registerOpenArtifacts(dataLinkSet,artifactTable);
        end

        function registerOpenArtifacts(this,dataLinkSet,artifactTable)





            sourceArtifact=dataLinkSet.artifact;
            [~,linkSetSourceArtifactName,~]=fileparts(sourceArtifact);
            artifactTable(end+1,this.ARTIFACT_NAME_COLUMN)=linkSetSourceArtifactName;
            artifactTable(end,this.ARTIFACT_DOMAIN_COLUMN)=slreq.utils.getDomainLabel(sourceArtifact);
            artifactTable(end,this.ARTIFACT_PATH_COLUMN)=sourceArtifact;

            [artifactRows,~]=size(artifactTable);
            for i=1:artifactRows
                artifactName=char(artifactTable(i,this.ARTIFACT_NAME_COLUMN));
                artifactDomain=char(artifactTable(i,this.ARTIFACT_DOMAIN_COLUMN));
                artifactPath=char(artifactTable(i,this.ARTIFACT_PATH_COLUMN));

                if this.isArtifactLoaded(artifactName,artifactPath,artifactDomain)


                    slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","As "+artifactName+" is loaded, adding references",'I');
                    this.addReference(dataLinkSet,artifactPath);
                end
            end
        end

        function openLinkSetsForRegisteredArtifacts(this)






            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Opening linksets for already opened artifacts",'I');


            stopUserActionObj=slreq.app.MainManager.startUserAction();%#ok<NASGU>

            if this.isSimulinkProjectOpen
                artifactKeys=this.lsmHandler.getProjectArtifacts();
            else
                artifactKeys=this.lsmHandler.getMATLABPathArtifacts();
            end

            for i=1:length(artifactKeys)
                artifact=strsplit(string(artifactKeys{i}),this.ARTIFACT_PROP_SEPARATOR);
                artifactName=artifact(1);
                artifactDomain=artifact(2);
                if artifactName=="_linkset"||isempty(artifactDomain)

                    continue;
                end
                if this.isArtifactLoaded(artifactName,artifactName,artifactDomain)





                    switch artifactDomain
                    case 'linktype_rmi_simulink'
                        domainExt='.slx';
                    case 'linktype_rmi_matlab'
                        domainExt='.m';
                    case 'linktype_rmi_data'
                        domainExt='.sldd';
                    case 'linktype_rmi_testmgr'
                        domainExt='.mldatx';
                    case 'linktype_rmi_slreq'
                        domainExt='.slreqx';
                    end
                    artifactFile=sprintf('%s%s',artifactName,domainExt);
                    slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","loading incoming linksets for "+string(artifactName)+" artifact",'I');
                    this.loadIncomingLinkSetsFor(artifactFile);
                end
            end
        end

        function artifactIsLoaded=isArtifactLoaded(~,artifactName,artifactPath,artifactDomain)
            artifactIsLoaded=false;


            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","checking whether artfact "+artifactName+" is loaded",'I');
            switch artifactDomain
            case 'linktype_rmi_slreq'
                artifactIsLoaded=~isempty(slreq.data.ReqData.getInstance.getReqSet(artifactName));
            case 'linktype_rmi_simulink'
                artifactIsLoaded=dig.isProductInstalled('Simulink')&&is_simulink_loaded()...
                &&bdIsLoaded(artifactName);
            case 'linktype_rmi_testmgr'








                licenses=license('inuse');
                artifactIsLoaded=ismember('simulink_test',{licenses.feature})...
                &&ismember(artifactName,{sltest.testmanager.getTestFiles().Name});
            case 'linktype_rmi_data'



                artifactIsLoaded=dig.isProductInstalled('Simulink')&&is_simulink_loaded()...
                &&~isempty(Simulink.dd.getOpenDictionaryPaths(artifactName+".sldd"));
            case 'linktype_rmi_matlab'
                artifactIsLoaded=rmiut.RangeUtils.isOpenInEditor(artifactPath);
            end
        end

        function artifactInfo=getLinkDestinations(this,linkSet)

            artifactInfo=strings(0,3);





            if isa(linkSet,'slreq.data.LinkSet')
                allLinks=linkSet.getAllLinks();
                numLinks=numel(allLinks);
                artifactInfo=strings(numLinks,3);
                for i=1:length(allLinks)
                    link=allLinks(i);
                    linkDest=link.dest;



                    if~isempty(linkDest)
                        if~linkDest.isDirectLink
                            reqSet=linkDest.getReqSet;

                            artifactInfo(i,this.ARTIFACT_NAME_COLUMN)=string(reqSet.name);
                            artifactInfo(i,this.ARTIFACT_DOMAIN_COLUMN)="linktype_rmi_slreq";
                            artifactInfo(i,this.ARTIFACT_PATH_COLUMN)=string(reqSet.filepath);
                        else







                            linkArtifactURI=linkDest.artifactUri;
                            [~,artifactName,~]=fileparts(linkArtifactURI);
                            artifactInfo(i,this.ARTIFACT_NAME_COLUMN)=string(artifactName);
                            artifactInfo(i,this.ARTIFACT_DOMAIN_COLUMN)=string(linkDest.domain);
                            artifactInfo(i,this.ARTIFACT_PATH_COLUMN)=string(linkArtifactURI);
                        end
                    end
                end
            elseif isa(linkSet,'slreq.datamodel.LinkSet')
                allLinks=linkSet.links;
                linkKeys=allLinks.keys;
                numLinks=double(allLinks.Size);
                artifactInfo=strings(numLinks,3);

                for i=1:numLinks
                    link=allLinks.getByKey(linkKeys(i));
                    linkDest=link.dest;



                    if contains(linkDest.artifactUri,this.ARTIFACT_SELF_REF_TAG)




                        continue;
                    else
                        [~,artifactName,~]=fileparts(linkDest.artifactUri);
                    end
                    artifactInfo(i,this.ARTIFACT_NAME_COLUMN)=artifactName;
                    artifactInfo(i,this.ARTIFACT_DOMAIN_COLUMN)=linkDest.domain;


                end
            end


            artifactInfo=unique(artifactInfo,'rows');



            artifactInfo(artifactInfo(:,1)=="",:)=[];

        end

        function tf=isScanRunning(this)
            tf=this.lsmHandler.scanExists();
        end

        function noteFilesMissingMetadata(this,mode)

            switch mode
            case this.MODE_PROJECT
                if~this.isSimulinkProjectOpen
                    return;
                end
                this.pushBannerMessage({message('Slvnv:slreq:NoLinkDependencies',...
                this.currentProject,...
                'matlab:slreq.linkmgr.LinkSetManager.onBannerLinkClick(''NoLinkDependencies'')')...
                ,message('Slvnv:slreq:NoLinkDependenciesHelp')});
            case this.MODE_MLPATH




                if this.hasPendingBannerMessage([],this.NO_UPDATE_VIEW_FOR_BANNER)||this.isSimulinkProjectOpen
                    return;
                end
                this.pushBannerMessage({message('Slvnv:slreq:NoLinkDependenciesMLPath',...
                'matlab:slreq.linkmgr.LinkSetManager.onBannerLinkClick(''NoLinkDependenciesMLPath'')')...
                ,message('Slvnv:slreq:NoLinkDependenciesHelp')});
            end
        end


        function pushBannerMessage(this,bannerMessageObjs)


            this.pendingBannerMessage=bannerMessageObjs;

            if slreq.app.MainManager.exists()
                if isa(this.lastBannerView,'slreq.gui.RequirementsEditor')

                    this.lastBannerView.updateToolbar();
                elseif isa(this.lastBannerView,'slreq.internal.gui.Editor')
                    this.lastBannerView.showNotification();
                elseif ishandle(this.lastBannerView)

                    rmisl.notify(this.lastBannerView,bannerMessageObjs{1},bannerMessageObjs{2});
                else


                    appmgr=slreq.app.MainManager.getInstance();
                    view=appmgr.requirementsEditor;
                    if~isempty(view)&&isvalid(view)
                        view.updateToolbar();
                        if isa(view,'slreq.internal.gui.Editor')
                            view.showNotification();
                        end
                    end
                end
            end
        end

        function tf=hasPendingBannerMessage(this,view,doUpdateView)





            if nargin<3
                doUpdateView=true;
            end

            tf=~isempty(this.pendingBannerMessage);
            if doUpdateView




                this.lastBannerView=view;
            end
        end

        function bannerMessageObjs=getPendingBannerMessage(this,view)



            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","getting the pending banner messages",'I');
            bannerMessageObjs=this.pendingBannerMessage;
            this.lastBannerView=view;
        end

        function clearPendingBannerMessage(this,doRefresh)



            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","resetting the flag for pending banner message",'I');
            this.pendingBannerMessage=[];


            if~doRefresh||~slreq.app.MainManager.exists()
                return;
            end
            if isa(this.lastBannerView,'slreq.gui.RequirementsEditor')

                this.lastBannerView.updateToolbar();
            elseif isa(this.lastBannerView,'slreq.internal.gui.Editor')
                this.lastBannerView.dismissNotificationBanner;
            elseif ishandle(this.lastBannerView)

                rmisl.notify(this.lastBannerView,'');
            end
        end



        function addReference(this,dataLinkSet,callerArtifact)
            [domain,artifactName]=slreq.utils.getDomainLabel(callerArtifact);
            this.lsmHandler.addReference(dataLinkSet.filepath,artifactName,domain);
        end

        function currentRefCount=removeReference(this,dataLinkSet,callerArtifact)
            [artifactDomain,artifactName]=slreq.utils.getDomainLabel(callerArtifact);
            linksetFilepath=dataLinkSet.filepath;
            currentRefCount=this.lsmHandler.removeReference(linksetFilepath,artifactName,artifactDomain);
        end

        function clearAllReferencesForLinkSet(this,dataLinkSet)
            this.lsmHandler.clearAllReferences(dataLinkSet.filepath);
        end

        function forceCloseLinkSetsFromProject(this)


            rd=slreq.data.ReqData.getInstance;
            openLinkSets=rd.getLoadedLinkSets();
            projectFiles=this.getProjectFiles();
            if isempty(openLinkSets)||isempty(projectFiles)
                return;
            end

            for i=1:length(openLinkSets)
                oneDataLinkSet=openLinkSets(i);
                oneLinkSetFilePath=oneDataLinkSet.filepath;
                if ismember(string(oneLinkSetFilePath),projectFiles)
                    this.clearAllReferencesForLinkSet(oneDataLinkSet);
                    oneDataLinkSet.discard();
                end
            end
        end



        function onReqSetLoad(this,eventdata)

            switch(eventdata.type)
            case 'ReqSet Loaded'


                artifactPath=eventdata.eventObj.filepath;
                dataReqSet=eventdata.eventObj;
                if isa(dataReqSet,'slreq.data.RequirementSet')
                    artifactPath=slreq.internal.LinkUtil.getParentPath(dataReqSet);
                end

                this.onArtifactLoad(artifactPath);


                dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
                if~isempty(dataLinkSet)
                    this.addReference(dataLinkSet,dataLinkSet.artifact);
                end
            case 'Before ReqSet Discarded'

                this.onArtifactClose(eventdata.eventObj.filepath);
            end
        end

        function onArtifactLoad(this,artifactFileFullPath)


            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Artifact "+artifactFileFullPath+" loaded",'I');
            stopUserActionObj=slreq.app.MainManager.startUserAction();%#ok<NASGU>

            this.loadIncomingLinkSetsFor(artifactFileFullPath);
        end

        function onArtifactClose(this,artifactFile)
            [artifactDomain,artifactName]=slreq.utils.getDomainLabel(artifactFile);
            linksets=this.lsmHandler.getReferencedLinksets(artifactName,artifactDomain);
            reqData=slreq.data.ReqData.getInstance();
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","removing the references of linksets with "+artifactName+" artifact",'I');
            for i=1:length(linksets)


                dataLinkSet=reqData.getLinkSetByFilepath(linksets{i});



                reqData.discardLinkSet(dataLinkSet,artifactFile);
            end
        end

        function onLinkSetSave(this,dataLinkSet)

            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","linkset "+dataLinkSet.name+" is saved",'I');
            this.buildMetadataForLinksetFile(dataLinkSet.filepath);
            this.lsmHandler.scanSync(this.LSMH_MODE_FILE,{dataLinkSet.filepath});
            this.registerOpenArtifactsForLinkSet(dataLinkSet);
        end

        function onLinkSetSaveAs(this,dataLinkSet,oldArtifactPath,newArtifactPath,domain)



            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","moving the references from old artifact "+oldArtifactPath+" to the new artifact "+newArtifactPath,'I');
            this.lsmHandler.updateRefsForSaveAs(oldArtifactPath,dataLinkSet.filepath);



            [~,oldArtifactName,~]=fileparts(oldArtifactPath);
            this.lsmHandler.removeReference(dataLinkSet.filepath,oldArtifactName,domain);
        end

        function tf=isSimulinkProjectOpen(this)
            tf=~isempty(this.currentProject);
        end

        function onProjectOpen(this,projectName)
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Project "+projectName+" has opened",'I');
            this.currentProject=projectName;

            files=slreq.linkmgr.LinkSetManager.getProjectFiles();
            this.lsmHandler.scanAsync(this.LSMH_MODE_PROJECT,files);
        end

        function onProjectClose(this)

            stopUserActionObj=slreq.app.MainManager.startUserAction();



            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Project has closed",'I');
            this.lsmHandler.clearProjectCache();
            this.clearPendingBannerMessage(false);
            this.pendingProjectFilesToSaveMetadata={};

            if this.closeLinkSetsOnProjectClose
                this.forceCloseLinkSetsFromProject();
            end

            this.currentProject=[];


            if slreq.app.MainManager.exists()
                this.scanMATLABPathOnSlreqInit(this.METADATA_SCAN_INIT_MODE_UI);
            end
        end

        function onScanFinish(this,scanType)
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr",scanType+" Scan is finished",'I');
            if nargin<2
                scanType='';
            end
            if scanType==this.LSMH_MODE_FILE


                return;
            end





            if this.doLoadIncomingLinks
                this.openLinkSetsForRegisteredArtifacts();
            end
        end

        function setIncomingLinksLoading(this,tf)
            this.doLoadIncomingLinks=tf;
        end

        function writeSLMXMetadata(this,linkSetFile,destinationArtifacts)
            import matlab.io.xml.dom.*

            xmlMetaDoc=this.createXMLMetadataDocumentForNonProject(destinationArtifacts);


            package=slreq.opc.Package(linkSetFile);
            serializedMetadata=writeToString(DOMWriter,xmlMetaDoc);
            try
                if package.hasLinkMetadata()
                    package.removeLinkMetadata();
                end
                package.saveLinkMetadata(serializedMetadata);
            catch e






            end
        end

        function docRoot=createXMLMetadataDocumentForNonProject(this,destinationArtifacts)
            import matlab.io.xml.dom.*

            docRoot=Document(this.REQ_META_ROOT_NODE);
            docRootNode=docRoot.getDocumentElement;
            outgoingLinkNode=docRoot.createElement(this.OUTGOING_LINKDATA_NODE);
            [numArtifacts,~]=size(destinationArtifacts);
            for i=1:numArtifacts
                newArtifactNode=docRoot.createElement(this.ARTIFACT_DATA_NODE);
                newArtifactNode.setAttribute(this.ARTIFACT_NAME_ATTRIBUTE,...
                destinationArtifacts(i,this.ARTIFACT_NAME_COLUMN));
                newArtifactNode.setAttribute(this.ARTIFACT_DOMAIN_ATTRIBUTE,...
                destinationArtifacts(i,this.ARTIFACT_DOMAIN_COLUMN));
                outgoingLinkNode.appendChild(newArtifactNode);
            end

            docRootNode.appendChild(outgoingLinkNode);
        end
    end

    methods(Static,Hidden)
        function onBannerLinkClick(messageId)
            lsm=slreq.linkmgr.LinkSetManager.getInstance;
            slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","Banner link with message ID "+messageId+" clicked",'I');


            switch messageId
            case 'NoLinkDependencies'
                helpview(fullfile(docroot,'slrequirements','helptargets.map'),'review_req_links');
                lsm.clearPendingBannerMessage(true);
            case 'NoLinkDependenciesMLPath'
                helpview(fullfile(docroot,'slrequirements','helptargets.map'),'review_req_links');
                lsm.clearPendingBannerMessage(true);
            case 'LinkDependencyScanFailedProject'
                lsm.reIndexMetadata(lsm.NO_CREATE_METADATA_IN_SLMX);
            case 'LinkDependencyScanFailedMLPath'
                lsm.reIndexMetadata(lsm.NO_CREATE_METADATA_IN_SLMX);
            case 'clear'
                lsm.clearPendingBannerMessage(true);
            end
        end

        function onLSMHandlerEvent(eventType,scanType,scanId,data)
            if nargin<4
                data=[];
            end
            if nargin<3
                scanId="";
            end
            if nargin<2
                scanType="";
            end
            if~slreq.linkmgr.LinkSetManager.exists()
                return;
            end
            lsm=slreq.linkmgr.LinkSetManager.getInstance();
            if~lsm.lsmHandler.scanExistsById(scanId)
                return;
            end
            switch eventType
            case lsm.LSMH_EVENT_SCAN_FINISHED



                if scanType==lsm.LSMH_MODE_PROJECT
                    lsm.pendingProjectFilesToSaveMetadata=data;
                    if~isempty(data)
                        slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","In order to show banner, noting the missing files",'I');
                        lsm.noteFilesMissingMetadata(lsm.MODE_PROJECT);
                    end
                elseif scanType==lsm.LSMH_MODE_MATLAB
                    lsm.pendingPathFilesToSaveMetadata=data;
                    if~isempty(data)
                        slreq.linkmgr.LSMHandler.logEvent("slreq::linkmgr","In order to show banner, noting the missing files",'I');
                        lsm.noteFilesMissingMetadata(lsm.MODE_MLPATH);
                    end
                end
                lsm.onScanFinish(scanType);
            otherwise

            end
            lsm.lsmHandler.removeScan(scanId);
        end

        function files=getProjectFiles()
            try
                files=slreq.linkmgr.LinkSetMetadataHandler.getAllProjectFiles();
            catch ex %#ok<NASGU>

                files={};
            end
        end
    end
end













