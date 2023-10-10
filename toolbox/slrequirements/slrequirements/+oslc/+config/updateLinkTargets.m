function varargout=updateLinkTargets(oldId,newId,srcInfo)

    reportCount='';
    mapCount=containers.Map('KeyType','char','ValueType','double');


    oldId=strrep(oldId,'/','%2F');
    newId=strrep(newId,'/','%2F');

    if nargin==3

        linkSet=slreq.internal.getDataLinkSet(srcInfo);
        if~isempty(linkSet)
            processLinkSet(linkSet);
        end
    else

        linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();


        for i=1:numel(linkSets)
            processLinkSet(linkSets(i));
        end
    end


    varargout{1}=mapCount;
    if nargout>1
        varargout{2}=reportCount;
    end

    function processLinkSet(oneLinkSet)
        [~,aName,aExt]=fileparts(oneLinkSet.artifact);
        count=oneLinkSet.updateDocUri(oldId,newId);
        if count>0
            artifactName=[aName,aExt];
            mapCount(artifactName)=count;
            reportCount=[reportCount,newline...
            ,getString(message('Slvnv:oslc:UpdatedNLinks',num2str(count),artifactName))];
        end
    end
end

