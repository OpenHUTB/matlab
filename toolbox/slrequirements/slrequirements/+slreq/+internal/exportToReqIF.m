







































































function out=exportToReqIF(reqSetName,reqIFName,dataRootItem,exportMapping,exportMode,templateFile,noImages,linkOptions)


    if nargin<6
        templateFile=[];
    end
    if nargin<7
        noImages=false;
    end
    if nargin<8
        linkOptions=struct('exportLinks',true,'minimalAttributes',false);
    end


    reqData=slreq.data.ReqData.getInstance();
    dataReqSet=reqData.loadReqSet(reqSetName);
    if isempty(dataReqSet)
        error('Invalid reqset.');
    end

    if isempty(dataRootItem)
        dataRootItem=slreq.data.Requirement.empty;
    end


    if isempty(exportMapping)
        if isempty(dataRootItem)
            error('Internal error: if not specifying mapping, must select an import node');
        else
            mfMapping=reqData.getMapping(dataReqSet,dataRootItem.customId);
        end
    else
        mfMapping=reqData.loadMapping(exportMapping);
    end

    if isempty(mfMapping)

        error('Invalid mapping file or file not found.');
    end


    direction=reqData.getMappingDirection(mfMapping);
    if direction==slreq.datamodel.MappingDirectionEnum.Import

        mfMapping=mfMapping.invert();
    else

    end


    direction=reqData.getMappingDirection(mfMapping);
    if direction~=slreq.datamodel.MappingDirectionEnum.Export
        error('Internal error: was expecting an Export mapping');
    end


    slreq.internal.addCustomAttributes(dataReqSet,mfMapping);



    if~isempty(dataRootItem)&&dataRootItem.external&&~dataRootItem.isReqIF()&&isempty(templateFile)

        exportMode=slreq.internal.ExportMode.CreateNewFile;
    end

    mfTemplate=[];

    switch(exportMode)
    case slreq.internal.ExportMode.CreateNewFile
        foundTemplate=false;
        if~isempty(exportMapping)
            [filepath,filename,~]=fileparts(exportMapping);
            if strcmp(filename,'genericReqIF_mapping')
                templateFile=fullfile(filepath,'genericReqIF_template.reqif');
                mfTemplateXml=slreq.utils.readFromXML(templateFile);
                if~isempty(mfTemplateXml)
                    mfTemplateXml=slreq.internal.prepareReqIFtemplate(mfTemplateXml);

                    mfTemplate=reqData.importReqIFTemplate(mfTemplateXml,mfMapping);
                    foundTemplate=true;
                end
            end
        end

        if foundTemplate
            [mfReqIf,mfReqIfModel]=reqData.exportToReqIFTemplate(dataReqSet,dataRootItem,mfTemplate,mfMapping,linkOptions);
        else
            [mfReqIf,mfReqIfModel]=reqData.exportToReqIF(dataReqSet,dataRootItem,mfMapping);
        end

    case slreq.internal.ExportMode.UpdateExistingSpec


        if isempty(templateFile)
            attachMgr=slreq.attach.AttachmentManager(dataReqSet.filepath);

            [templateFile,templateName,templateLocation]=slreq.internal.getReqIFTemplateName();


            attachMgr.downloadAttachment(dataReqSet,num2str(dataRootItem.sid),templateName,templateLocation);
        end

        mfTemplateXml=slreq.utils.readFromXML(templateFile);
        if isempty(mfTemplateXml)
            error('Internal error: cannot find the template.');
        end


        mfTemplateXml=slreq.internal.prepareReqIFtemplate(mfTemplateXml);








        importMapping=mfMapping.invert();





        mfTemplate=reqData.importReqIFTemplate(mfTemplateXml,importMapping);





        [mfReqIf,mfReqIfModel]=reqData.exportToReqIFTemplate(dataReqSet,dataRootItem,mfTemplate,mfMapping,linkOptions);

    otherwise

        error('Unsupported export mode');
    end



    [xmlString,imageFiles]=reqData.serializeReqIF(mfReqIf);


    mfReqIf.destroy();


    mfReqIfModel.destroy();


    mfMapping.destroy();


    if~isempty(mfTemplate)
        mfTemplate.destroy();
    end


    scratchDir=fullfile(tempdir,'RMI','scratch','REQIF');
    if exist(scratchDir,'dir')==7
        rmdir(scratchDir,'s');
    end
    mkdir(scratchDir);



    imagesToPack=dataReqSet.getImageFilenamesToPack();
    imageCount=0;
    if~noImages&&~isempty(imagesToPack)

        imageCount=copyImages(imagesToPack,scratchDir,dataReqSet.name);
    end


    [~,~,fExt]=fileparts(reqIFName);
    if imageCount>0||strcmpi(fExt,'.reqifz')

        scratchFile=fullfile(scratchDir,'slreqs_export.reqif');
        slreq.utils.writeToXML(scratchFile,xmlString);

        [fPath,fName,~]=fileparts(reqIFName);

        zipFileName=fullfile(fPath,[fName,'.zip']);

        reqifzFileName=fullfile(fPath,[fName,'.reqifz']);

        zip(zipFileName,{'*'},scratchDir);

        movefile(zipFileName,reqifzFileName);
    else
        slreq.utils.writeToXML(reqIFName,xmlString);
    end

    out=true;
end

function template=loadBuiltinTemplate(fullPathToTemplateFile,importMapping,reqData)

    builtinTemplateXml=slreq.utils.readFromXML(fullPathToTemplateFile);
    if isempty(builtinTemplateXml)
        rmiut.warnNoBacktrace('Slvnv:rmigraph:MissingFile',fullPathToTemplateFile);
        return;
    end
    builtinTemplateXml=slreq.internal.prepareReqIFtemplate(builtinTemplateXml);
    template=reqData.importReqIFTemplate(builtinTemplateXml,importMapping);
end








function imageCount=copyImages(imagesToPack,destDir,reqSetName)

    imageCount=0;


    baseReqIfDir='SLREQ_RESOURCE/REQIF/';
    baseReqIfDirLen=length(baseReqIfDir);


    destDir=strrep(destDir,filesep,'/');

    imageMgr=slreq.opc.ImageManager(reqSetName);




    attachmentsDir='SLREQ_RESOURCE/ATTACHMENTS';
    attachmentsDirLen=length(attachmentsDir);

    for n=1:length(imagesToPack)
        imageToPack=imagesToPack{n};


        if strncmp(imageToPack,attachmentsDir,attachmentsDirLen)
            continue;
        end

        imageCount=imageCount+1;

        [srcPath,macroUsed]=imageMgr.unpackImages(imageToPack);


        if strncmp(imageToPack,baseReqIfDir,baseReqIfDirLen)


            imagePath=imageToPack(baseReqIfDirLen+1:end);
            dstPath=fullfile(destDir,imagePath);
        else


            dstPath=imageMgr.unpackImages(imageToPack,fullfile(destDir,macroUsed));
        end


        if startsWith(dstPath,'file:///')
            dstPath=dstPath(9:end);
        end

        parentPath=fileparts(dstPath);
        if~exist(parentPath,'dir')
            mkdir(parentPath);
        end

        try
            copyfile(srcPath,dstPath);
        catch ex

            debug=0;
        end
    end
end


