

































function[reqSet,count,topNodes]=importFromReqIF(reqSetName,reqIFname,mappingFile,asReferences,asMultipleReqSets,singleSpec,importLinks)




    if nargin<4
        asReferences=true;
    end

    if nargin<5
        asMultipleReqSets=false;
    end

    if nargin<6
        singleSpec='';
    end

    if nargin<7
        importLinks=true;
    end



    [~,fName,fExt]=fileparts(reqIFname);


    if isempty(reqSetName)

        reqSetName=fName;
    end





    reqData=slreq.data.ReqData.getInstance();
    dataReqSet=reqData.getReqSet(reqSetName);
    if isempty(dataReqSet)
        reqSet=slreq.new(reqSetName);

        dataReqSet=reqData.getReqSet(reqSetName);
    else
        reqSet=slreq.utils.wrapDataObjects(dataReqSet);
    end



    reqData.setModifiedOn(dataReqSet,datetime());


    try
        mfMapping=reqData.loadMapping(mappingFile);
    catch ex %#ok<NASGU>
        mfMapping=reqData.createMapping();
    end


    direction=reqData.getMappingDirection(mfMapping);
    if direction~=slreq.datamodel.MappingDirectionEnum.Import
        error('Internal error: was expecting an Import mapping');
    end


    if strcmpi(fExt,'.reqifz')
        reqifzName=reqIFname;
        reqIFname=slreq.internal.scratchUnzipReqIF(reqIFname);



        [~,nameReqSet,~]=fileparts(reqSetName);

        imagePaths=slreq.internal.copyResourceFiles(reqIFname,nameReqSet);
        if~isempty(imagePaths)
            dataReqSet.collectImagesForPacking(imagePaths);
        end
    else
        reqifzName='';
    end

    mf0Xml=slreq.utils.readFromXML(reqIFname);
    if isempty(mf0Xml)
        error(message('Slvnv:slreq_import:FileNotFound',reqIFname));
    end



    [count,topNodes]=reqData.importFromReqIF(mf0Xml,reqIFname,dataReqSet,mfMapping,asReferences,asMultipleReqSets,singleSpec,importLinks,reqifzName);






    if~isempty(reqifzName)
        for ii=1:length(topNodes)
            topNodes{ii}.artifactUri=reqifzName;
        end
    end







    for ii=1:length(topNodes)
        topNode=topNodes{ii};
        importedReqSet=topNode.getReqSet();





        attachMgr=slreq.attach.AttachmentManager(importedReqSet.filepath);
        [templateFile,~,~]=slreq.internal.getReqIFTemplateName();

        slreq.internal.prepareReqIFtemplate(mf0Xml);

        attachMgr.addAttachment(importedReqSet,num2str(topNode.sid),templateFile);
    end


    if asMultipleReqSets
        for ii=1:length(topNodes)

            importedReqSet=topNodes{ii}.getReqSet();
            importedReqSet.save();
        end
    else
        dataReqSet.save();
    end


    updateDetectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
    updateDetectionMgr.checkUpdatesForAllArtifacts();


    if slreq.app.MainManager.exists()
        for ii=1:length(topNodes)
            reqData.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',topNodes{ii}));
        end
    end

end

