


function duplicateImportOptionsFilesForArtifact(mfReqSet,oldArtifactUri,newArtifactUri,isFile)
    if nargin<4
        isFile=true;
    end
    if isFile
        duplicateImportOptionsWhenSrcIsFile(mfReqSet,oldArtifactUri,newArtifactUri);
    else
        duplicateImportOptionsWhenSrcIsNotFile(mfReqSet,oldArtifactUri,newArtifactUri);
    end
end

function duplicateImportOptionsWhenSrcIsNotFile(mfReqSet,oldArtifactId,newArtifactId)
    reqSetName=mfReqSet.name;
    oldOptionsFile=slreq.import.impOptFile(reqSetName,oldArtifactId);
    if exist(oldOptionsFile,'file')==2
        newOptionsFile=slreq.import.impOptFile(reqSetName,newArtifactId);


        importOptions=slreq.import.loadStoredOptions(reqSetName,oldArtifactId);
        if isfield(importOptions,'DocID')&&strcmp(importOptions.DocID,oldArtifactId)
            importOptions.DocID=newArtifactId;
        end
        save(newOptionsFile,'importOptions');
    end
end

function duplicateImportOptionsWhenSrcIsFile(mfReqSet,oldArtifactUri,newArtifactUri)





    reqSetName=mfReqSet.name;




    [~,oldArtifactName]=fileparts(oldArtifactUri);
    [~,newArtifactName]=fileparts(newArtifactUri);

    if strcmp(newArtifactName,oldArtifactName)
        return;
    end






    mfReqItems=mfReqSet.rootItems.toArray();
    for i=1:length(mfReqItems)
        mfReqItem=mfReqItems(i);


        if~isa(mfReqItem,'slreq.datamodel.ExternalRequirement')
            continue;
        end


        [docName,subDoc]=slreq.internal.getDocSubDoc(mfReqItem.customId);


        if~strcmp(docName,newArtifactName)
            continue;
        end



        oldOptionsFile=slreq.import.impOptFile(reqSetName,oldArtifactName,subDoc);
        if exist(oldOptionsFile,'file')==2
            newOptionsFile=slreq.import.impOptFile(reqSetName,newArtifactName,subDoc);


            importOptions=slreq.import.loadStoredOptions(reqSetName,oldArtifactName,subDoc);
            if isfield(importOptions,'DocID')&&strcmp(importOptions.DocID,oldArtifactName)
                importOptions.DocID=newArtifactName;
            end
            save(newOptionsFile,'importOptions');
        end
    end

end