function[count,topNodes]=importFromReqIF(this,mf0Xml,artifactUri,dataReqSet,mapping,asReferences,asMultipleReqSets,singleSpec,importLinks,reqifzName)






    if isempty(mf0Xml)

        error(message('Slvnv:slreq_import:FileNotFound',artifactUri));
    end

    if nargin<6
        asReferences=true;
    end

    if nargin<7
        asMultipleReqSets=false;
    end

    if nargin<8
        singleSpec='';
    end

    if nargin<9
        importLinks=false;
    end

    if nargin<10
        reqifzName=[];
    end


    topNodes={};


    dataSpecLinkSets={};

    dataSpecReqSets={};


    mfReqIfModel=mf.zero.Model();
    adapter=slreq.datamodel.ReqIFAdapter(mfReqIfModel);



    mfReqIf=adapter.importFromReqIf(mf0Xml,mapping);

    [fPath,~,~]=fileparts(artifactUri);




    if isempty(reqifzName)
        imgArray=adapter.embeddedImages.toArray();
        opcPaths=copyEmbeddedImages(fPath,imgArray,dataReqSet);
        if~isempty(opcPaths)
            dataReqSet.collectImagesForPacking(opcPaths);
        end
    end

    coreContent=mfReqIf.coreContent;

    try
        checkForSpecNameConflicts(dataReqSet.children,coreContent);
    catch ex
        shorterFileName=slreq.uri.getShortNameExt(artifactUri);
        error(message('Slvnv:slreq_import:UnableToImportForReason',shorterFileName,dataReqSet.name,ex.message));
    end



    try


        toolId=mfReqIf.theHeader.sourceToolId;
        reqifPrefix=slreq.data.Requirement.REQIF_DOMAIN_PREFIX;
        domain=[reqifPrefix,toolId];


    catch ex



        rmiut.warnNoBacktrace('Slvnv:slreq_import:UnknownSourceAppID',artifactUri,ex.message);



        domain='ReqIF';
    end


    mfRelationsSequence=mfReqIf.coreContent.specRelations;
    hasLinks=false;
    if~isempty(mfRelationsSequence)
        hasLinks=(mfRelationsSequence.Size>0);
    end







    reqSetLocation=fileparts(dataReqSet.filepath);

    rootItem=[];
    mfSpecs=coreContent.specifications.toArray();
    for idx=1:length(mfSpecs)
        mfSpec=mfSpecs(idx);
        specName=mfSpec.longName;



        if isempty(specName)
            specName=mfSpec.identifier;
        end

        if~isempty(singleSpec)&&~strcmp(specName,singleSpec)

            continue;
        end

        mfSpecReqSet=[];

        specType=mfSpec.type;
        if~isempty(specType)
            specTypeName=specType.longName;
            isProxySpec=slreq.cpputils.isProxySpecification(specTypeName);

            if isProxySpec

                if hasLinks
                    specDomain=slreq.cpputils.getProxyDomainBySpecTypeName(specTypeName);
                    proxyArtifact=rebuildProxyArtifact(reqSetLocation,mfSpec.longName,specDomain);
                    if~isempty(proxyArtifact)
                        dataSpecLinkSet=this.getLinkSet(proxyArtifact,specDomain);
                        if isempty(dataSpecLinkSet)


                            linkFilename=rmimap.StorageMapper.getInstance.getStorageFor(proxyArtifact);

                            if isfile(linkFilename)
                                dataSpecLinkSet=this.loadLinkSet(proxyArtifact,linkFilename);
                            else


                                mfLinkSet=this.addLinkSet(proxyArtifact,specDomain);
                                dataSpecLinkSet=this.wrap(mfLinkSet);
                                dataSpecLinkSets{end+1}=dataSpecLinkSet;
                            end
                        end
                    end
                end
                continue;
            end
        end


        if idx==1
            mfSpecReqSet=this.getModelObj(dataReqSet);
            dataSpecReqSet=dataReqSet;
            dataSpecReqSets{end+1}=dataSpecReqSet;
        else
            if asMultipleReqSets
                legalFileName=slreq.cpputils.makeSafeFileName(specName);
                specReqSetName=fullfile(reqSetLocation,[legalFileName,'.slreqx']);
                dataSpecReqSet=this.createAndSaveReqSet(specReqSetName);
                mfSpecReqSet=this.getModelObj(dataSpecReqSet);
                dataSpecReqSets{end+1}=dataSpecReqSet;
            else
                mfSpecReqSet=this.getModelObj(dataReqSet);
                dataSpecReqSet=dataReqSet;
            end
        end







        reqInfo.id=specName;


        reqInfo.artifactId='';


        reqInfo.typeName=slreq.custom.RequirementType.Container.char;

        if asReferences


            groupUri=strrep(artifactUri,'\','/');






            group=this.getGroup(groupUri,domain,mfSpecReqSet);





            reqInfo.group=group;
            reqInfo.domain=domain;
            reqInfo.artifactUri=groupUri;



            specRootItem=this.addExternalRequirement(dataSpecReqSet,reqInfo);
        else

            reqInfo.group=[];
            reqInfo.domain='';
            reqInfo.artifactUri='';
            reqInfo.summary='';
            reqInfo.description='';



            specRootItem=this.addRequirement(dataSpecReqSet,reqInfo);
        end

        topNodes{end+1}=specRootItem;

        if idx==1

            rootItem=specRootItem;
        end

        dataSpecLinkSet=[];
        if hasLinks

            artifact=mfSpecReqSet.filepath;
            dataSpecLinkSet=this.getLinkSet(artifact,'linktype_rmi_slreq');
            if isempty(dataSpecLinkSet)


                mfLinkSet=this.addLinkSet(artifact,'linktype_rmi_slreq');

                dataSpecLinkSet=this.wrap(mfLinkSet);

                dataSpecLinkSets{end+1}=dataSpecLinkSet;
            end


            adapter.linkSet=dataSpecLinkSet.getModelObj();


            dataSpecLinkSet.addRegisteredRequirementSet(dataSpecReqSet);
        end
    end

    adapter.multipleReqSets=asMultipleReqSets;
    adapter.singleSpec=singleSpec;
    adapter.importLinks=importLinks;







    if~isempty(rootItem)
        mfRootItem=rootItem.getModelObj();
    else
        mfRootItem=slreq.datamodel.RequirementItem.empty();
    end


    count=adapter.importIntoRequirementSet(mfReqIf,mapping,dataReqSet.getModelObj(),mfRootItem);


    for i=1:length(dataSpecLinkSets)
        dataSpecLinkSet=dataSpecLinkSets{i};
        if numel(dataSpecLinkSet.getAllLinks())>0


            dataSpecLinkSet.save();
            this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSet Loaded',dataSpecLinkSet));
            slreq.internal.Events.getInstance.notify('LinkSetLoaded',slreq.internal.LinkSetEventData(dataSpecLinkSet));
        end
    end




    mfReqIfModel.destroy();




    if length(topNodes)==1
        if~isempty(mapping)&&~strcmp(dataReqSet.name,'SCRATCH')

            mapping.name=topNodes{1}.customId;

            this.addMapping(dataReqSet,mapping);
        end
    else


        for ii=1:length(topNodes)
            topNode=topNodes{ii};
            importedReqSet=topNode.getReqSet();
            if~isempty(mapping)&&~strcmp(dataReqSet.name,'SCRATCH')




                clonedMapping=mapping.invert().invert();
                clonedMapping.name=topNode.customId;

                this.addMapping(importedReqSet,clonedMapping);
            end
        end
    end
end

function checkForSpecNameConflicts(dataTopNodes,reqifContent)
    if isempty(reqifContent)
        error(message('Slvnv:slreq_import:MissingRequirements'));
    end
    reqifSpecSequence=reqifContent.specifications;
    if reqifSpecSequence.Size==0
        error(message('Slvnv:reqmgt:reqif:MissingSpecification'));
    end
    if isempty(dataTopNodes)
        return;
    end
    topNodeIds={dataTopNodes.customId};
    specArray=reqifSpecSequence.toArray();
    for i=1:numel(specArray)
        specName=specArray(1).longName;
        if any(strcmp(topNodeIds,specName))
            reqSetFileName=slreq.uri.getShortNameExt(dataTopNodes(1).getReqSetArtifactUri);
            error(message('Slvnv:slreq_import:DocWasImportedInto',specName,reqSetFileName));
        end
    end









end

function artifact=rebuildProxyArtifact(reqSetLocation,specName,proxyDomain)
    artifact='';
    extension=slreq.uri.FilePathHelper.getExtensionForDomain(proxyDomain);

    if~isempty(extension)
        artifactName=[specName,extension];

        existingArtifact=which(artifactName);
        if~isempty(existingArtifact)
            artifact=existingArtifact;
        elseif strcmp(extension,'.slx')
            existingArtifact=which([specName,'.mdl']);
            if~isempty(existingArtifact)
                artifact=existingArtifact;
            end
        end

        if isempty(artifact)
            artifact=fullfile(reqSetLocation,artifactName);
        end
    end

end

function opcPaths=copyEmbeddedImages(fPath,imgArray,dataReqSet)
    opcPaths={};
    imageMgr=slreq.opc.ImageManager(dataReqSet.name);
    reqifCacheDir=slreq.import.resourceCachePaths('REQIF');
    resourceBaseDir=slreq.opc.getUsrTempDir();

    for i=1:numel(imgArray)
        srcPath=imgArray{i};
        relPath=srcPath;
        if~isfile(srcPath)

            srcPath=fullfile(fPath,srcPath);
            if~isfile(srcPath)

                srcPath=[];
            end
        end

        if isempty(srcPath)

            continue
        end

        [destDir,imgName,imgExt]=fileparts(relPath);
        if~isempty(srcPath)

            [destDir,macroUsed]=imageMgr.unpackImages(destDir);
            if isempty(macroUsed)
                destDir=strrep(destDir,' ','_');
                destDir=fullfile(reqifCacheDir,destDir);
            end

            dest=fullfile(destDir,[imgName,imgExt]);

            dest_tmp=strrep(dest,'\','/');
            dest_tmp=strrep(dest_tmp,resourceBaseDir,'SLREQ_RESOURCE');

            opcPaths{end+1}=dest_tmp;%#ok<AGROW> 

            try
                if exist(destDir,'dir')~=7
                    mkdir(destDir);
                end
                copyfile(srcPath,dest);
            catch ex


                debug=0;
            end
        end
    end
end
