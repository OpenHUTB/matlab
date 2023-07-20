function[reqs,grps]=getDataForSid(srcSid,isSigBuilder)
    grps=[];

    if isSigBuilder
        [~,grps,reqs]=slreq.getSigbGrpData(srcSid);
    else
        reqs=rmidata.getReqs(srcSid);
    end
end
