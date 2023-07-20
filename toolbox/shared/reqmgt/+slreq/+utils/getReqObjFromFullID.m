function out=getReqObjFromFullID(fullid)





    ind=strsplit(fullid,':#');
    if length(ind)==2
        setName=ind{1};
        id=ind{2};
        reqData=slreq.data.ReqData.getInstance;
        reqSet=reqData.getReqSet(setName);
        if~isempty(reqSet)
            out=reqSet.getItemFromID(id);
        else

            out=[];
        end
    else
        out=[];
    end
end