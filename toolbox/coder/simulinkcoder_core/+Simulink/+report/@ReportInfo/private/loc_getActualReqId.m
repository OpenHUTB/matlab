

function out=loc_getActualReqId(reqId,reqs)
    nNonLinkedIds=0;
    for i=1:length(reqs)
        if~reqs(i).linked
            nNonLinkedIds=nNonLinkedIds+1;
        elseif i-nNonLinkedIds==reqId
            out=i;
            return
        end
    end
    out=str2double(reqId);

end
