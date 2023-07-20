
function out=hasImagesToExport(reqSetName)

    out=false;

    reqData=slreq.data.ReqData.getInstance();


    dataReqSet=reqData.getReqSet(reqSetName);
    if isempty(dataReqSet)
        error('Invalid reqset.');
    end

    imagesToPack=dataReqSet.getImageFilenamesToPack();

    attachmentsDir='SLREQ_RESOURCE/ATTACHMENTS';
    attachmentsDirLen=length(attachmentsDir);

    for n=1:length(imagesToPack)
        imageToPack=imagesToPack{n};


        if strncmp(imageToPack,attachmentsDir,attachmentsDirLen)
            continue;
        end

        out=true;
        break;
    end
end
