function msg=isExcludedPort(m2mObj,aBlk,aPortIdx)
    msg=0;
    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        aBlk=get_param(aBlk,'ReferenceBlock');
    elseif isa(aBlk,'double')
        aBlk=getfullname(aBlk);
    end

    if isKey(m2mObj.fExcludedPorts,aBlk)
        excludedPortFlags=m2mObj.fExcludedPorts(aBlk);
        msg=excludedPortFlags(aPortIdx);
    end
end