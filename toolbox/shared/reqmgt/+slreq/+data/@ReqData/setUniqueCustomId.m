








function setUniqueCustomId(this,group,req)

    oldCustomId=req.customId;
    otherReqs=group.externalReqs{oldCustomId};
    if~isempty(otherReqs)


        for i=1:length(otherReqs)
            otherReq=otherReqs(i);
            otherReq.uniqueCustomId=makeUniqueCustomId(otherReq.customId,otherReq.sid);
        end


        req.uniqueCustomId=makeUniqueCustomId(req.customId,req.sid);
    else

        req.uniqueCustomId=req.customId;
    end
end









function out=makeUniqueCustomId(customId,sid)
    out=sprintf('%s#%d',customId,sid);
end
