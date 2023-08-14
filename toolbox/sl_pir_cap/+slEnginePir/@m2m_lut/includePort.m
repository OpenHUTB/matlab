function msg=includePort(m2mObj,aBlk,aPortIdx)

    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        aBlk=get_param(aBlk,'ReferenceBlock');
    elseif isa(aBlk,'double')
        aBlk=getfullname(aBlk);
    end


    if isKey(m2mObj.fExcludedPorts,aBlk)
        excludedPortFlags=m2mObj.fExcludedPorts(aBlk);
    else
        return;
    end
    excludedPortFlags(aPortIdx)=0;
    m2mObj.fExcludedPorts(aBlk)=excludedPortFlags;
    if all(excludedPortFlags(:)==0)
        msg=['include ',aBlk,' in the transfomration'];
        m2mObj.include(aBlk);
    end
end