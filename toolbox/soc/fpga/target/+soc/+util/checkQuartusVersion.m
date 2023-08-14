function checkQuartusVersion()
    [stat,result]=system('quartus_sh -v');
    if(stat~=0)||contains(result,'Pro Edition')
        error(message('soc:msgs:NotFoundHDLTool','Intel Quartus Standard Edition'));
    end
    supportedVersion=soc.internal.getSupportedToolVersion('Intel');
    if~contains(result,supportedVersion)
        currentVersion=extractAfter(result,'Version');
        currentVersion=currentVersion(2:5);
        error(message('soc:msgs:unsupportHDLToolVersion','Quartus',currentVersion,supportedVersion));
    end
end