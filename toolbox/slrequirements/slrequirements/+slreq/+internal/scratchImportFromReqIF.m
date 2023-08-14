
function scratchReqSet=scratchImportFromReqIF(mainReqSet,importNode,reqIFname,mappingFile)



    if nargin<4
        mappingFile=[];
    end

    [~,~,fExt]=fileparts(reqIFname);

    reqData=slreq.data.ReqData.getInstance();




    options=struct;
    options.mappingFile=mappingFile;
    options.ReqSet=mainReqSet;
    options.docPath=reqIFname;
    options.AsReference=true;
    options.asMultiple=false;
    options.singleSpec='';
    options.importLinks=true;

    importOptions=slreq.internal.callback.ImportOptionFactory.createImportOptions('reqif',options);
    slreq.internal.callback.Utils.executeCallback(importNode,'preImportFcn',importNode.preImportFcn,importOptions);


    options=importOptions.exportOptions;


    if~strcmp(options.docPath,reqIFname)
        slreq.internal.updateSrcArtifactUri(importNode,options.docPath);
    end


    mainReqSet=options.ReqSet;
    reqIFname=options.docPath;


    dataReqSet=reqData.getReqSet(mainReqSet);
    if isempty(dataReqSet)
        error('Internal error: Invalid reqset.');
    end

    if~isfield(options,'mappingFile')||isempty(options.mappingFile)
        mapping=reqData.getMapping(dataReqSet,importNode.customId);
    else
        mapping=reqData.loadMapping(options.mappingFile);
    end
    if isempty(mapping)

        error('Internal error: mapping not found');



    end


    direction=reqData.getMappingDirection(mapping);
    if direction~=slreq.datamodel.MappingDirectionEnum.Import
        error('Internal error: was expecting an Import mapping');
    end


    slreq.internal.addCustomAttributes(dataReqSet,mapping);








    scratchReqSet=reqData.createSpecialReqSet('SCRATCH');

    reqData.setModifiedOn(scratchReqSet,dataReqSet.modifiedOn);

    scratchReqSet.lastNumericID=dataReqSet.lastNumericID+1;




    if strcmpi(fExt,'.reqifz')
        reqifzName=reqIFname;
        reqIFname=slreq.internal.scratchUnzipReqIF(reqIFname);



        imagePaths=slreq.internal.copyResourceFiles(reqIFname,dataReqSet.name);
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




    [~,topNodes]=reqData.importFromReqIF(mf0Xml,reqIFname,scratchReqSet,mapping,options.AsReference,options.asMultiple,options.singleSpec,options.importLinks,reqifzName);



    if~isempty(reqifzName)
        for ii=1:length(topNodes)
            topNodes{ii}.artifactUri=reqifzName;
        end
    end


end


