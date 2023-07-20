function out=getAnchorString(reqInfo)

    reqString=sprintf('%s:%d',reqInfo.getReqSet.name,reqInfo.sid);
    out=slreq.report.utils.getLinkTargetString(reqString);
end