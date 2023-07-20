function out=getLinkObjFromFullID(fullid)





    ind=strsplit(fullid,':#');
    if length(ind)==2
        setName=ind{1};
        id=ind{2};
        reqData=slreq.data.ReqData.getInstance;
        linkSet=reqData.getLoadedLinkSetByName(setName);
        if isempty(linkSet)

            out=[];
        else
            out=linkSet.getLinkFromID(id);
        end
    else
        out=[];
    end
end