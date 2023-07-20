

function duplicateImportOptionsFilesForReqSet(oldReqSetName,newReqSetName,mfReqSet)




    [~,oldReqSetName]=fileparts(oldReqSetName);
    [~,newReqSetName]=fileparts(newReqSetName);

    if strcmp(newReqSetName,oldReqSetName)
        return;
    end







    mfReqItems=mfReqSet.rootItems.toArray();
    for i=1:length(mfReqItems)
        mfReqItem=mfReqItems(i);


        if~isa(mfReqItem,'slreq.datamodel.ExternalRequirement')
            continue;
        end


        [docName,subDoc]=slreq.internal.getDocSubDoc(mfReqItem.customId);





        oldOptionsFile=slreq.import.impOptFile(oldReqSetName,docName,subDoc);
        if exist(oldOptionsFile,'file')==2

            newOptionsFile=slreq.import.impOptFile(newReqSetName,docName,subDoc);
            copyfile(oldOptionsFile,newOptionsFile);
        end
    end

end