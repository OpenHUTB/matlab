function msg=excludePort(m2mObj,aBlk,aPortIdx)
    msg='';
    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        aBlk=get_param(aBlk,'ReferenceBlock');
    elseif isa(aBlk,'double')
        aBlk=getfullname(aBlk);
    end

    numInPorts=str2num(get_param(aBlk,'NumberOfTableDimensions'));
    if isKey(m2mObj.fExcludedPorts,aBlk)
        excludedPortFlags=m2mObj.fExcludedPorts(aBlk);
    else
        excludedPortFlags=zeros(1,numInPorts);
    end
    excludedPortFlags(aPortIdx)=1;
    m2mObj.fExcludedPorts(aBlk)=excludedPortFlags;
    msg=['exclude ',aBlk,' from the transfomration'];
    m2mObj.exclude(aBlk);
end