function populateReqSetUri(~,mfRef)






    if~strcmp(mfRef.domain,'linktype_rmi_slreq')
        return;
    end

    sid=str2num(mfRef.artifactId);%#ok<ST2NM>
    if~isempty(sid)
        reqSetFileName=slreq.uri.getReqSetShortName(mfRef.artifactUri);
        mfRef.reqSetUri=sprintf('%s:%d',reqSetFileName,sid);
    end

end
