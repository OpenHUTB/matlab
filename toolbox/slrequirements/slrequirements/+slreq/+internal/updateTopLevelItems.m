

function updateTopLevelItems(mfReqSet,origUri,newUri,isFile)
    if nargin<4
        isFile=true;
    end
    if isFile
        updateTopLevelItemsWhenSrcIsFile(mfReqSet,origUri,newUri);
    else
        updateTopLevelItemsWhenSrcIsNotFile(mfReqSet,origUri,newUri);
    end
end

function updateTopLevelItemsWhenSrcIsNotFile(mfReqSet,origUri,newUri)
    mfReqItems=mfReqSet.rootItems.toArray();
    for i=1:length(mfReqItems)
        mfReqItem=mfReqItems(i);

        if~isa(mfReqItem,'slreq.datamodel.ExternalRequirement')
            continue;
        end

        if strcmp(mfReqItem.customId,origUri)
            mfReqItem.customId=newUri;
            mfReqItem.uniqueCustomId=newUri;
            if contains(mfReqItem.description,origUri)
                mfReqItem.description=strrep(mfReqItem.description,origUri,newUri);
            end
            break;
        end
    end
end

function updateTopLevelItemsWhenSrcIsFile(mfReqSet,origUri,newUri)





    [~,newUri]=fileparts(newUri);
    [~,origUri]=fileparts(origUri);




    if strcmp(newUri,origUri)
        return;
    end






    mfReqItems=mfReqSet.rootItems.toArray();
    for i=1:length(mfReqItems)
        mfReqItem=mfReqItems(i);


        if~isa(mfReqItem,'slreq.datamodel.ExternalRequirement')
            continue;
        end

        [docName,subDoc]=slreq.internal.getDocSubDoc(mfReqItem.customId);

        if~strcmp(docName,origUri)
            continue;
        end

        if~isempty(subDoc)
            newCustomId=[newUri,'!',subDoc];
        else
            newCustomId=newUri;
        end



        mfReqItem.customId=newCustomId;


        mfReqItem.uniqueCustomId=newCustomId;
    end

end