function updateTargetReference(this,linkObj,destInfo)









    persistent uriMap destFile destName
    if isempty(linkObj)
        uriMap=containers.Map('KeyType','char','ValueType','char');
        uriMap('SRC_PATH')='REL_PATH';
        destFile=destInfo;
        [~,destName]=fileparts(destFile);
        return;
    elseif isempty(uriMap)
        uriMap=containers.Map('KeyType','char','ValueType','char');
        destFile='';
        destName='';
    end

    if~isa(linkObj,'slreq.data.Link')
        error('Invalid argument: expected slreq.data.Link object');
    end

    if isa(destInfo,'slreq.data.Requirement')


        linkModelObj=this.getModelObj(linkObj);
        linkRefObj=linkModelObj.dest;

        origReqSetName=strtok(linkRefObj.reqSetUri,':');
        linkRefObj.reqSetUri=sprintf('%s:%d',destInfo.getReqSet.name,destInfo.sid);



        linkSource=linkObj.source;
        refPath=linkSource.artifactUri;
        if isKey(uriMap,refPath)
            linkRefObj.artifactUri=uriMap(refPath);
        else
            if isempty(destFile)
                destFile=destInfo.getReqSet.filepath;
                [~,destName]=fileparts(destFile);
            end
            if~isempty(destInfo.getReqSet.parent)
                linkRefObj.artifactUri=slreq.uri.getPreferredPath(destInfo.getReqSet.parent,refPath);
                rId=slreq.utils.getShortIdFromLongId(linkRefObj.artifactId);
                [~,fName,fExt]=fileparts(destInfo.getReqSet.filepath);
                linkRefObj.artifactId=slreq.internal.LinkUtil.makeCompositeId([fName,fExt],rId);
            else
                linkRefObj.artifactUri=slreq.uri.getPreferredPath(destFile,refPath);
            end
            uriMap(refPath)=linkRefObj.artifactUri;
        end

        if~strcmp(destName,origReqSetName)
            linkRefObj.link.description=strrep(linkRefObj.link.description,origReqSetName,destName);
        end














    else
        error('Invalid argument type: %s',class(destInfo));
    end


    linkObj.setDirty(true);

end
