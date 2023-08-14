function ccLibFullPath=getCustomLibNameFromModel(modelName,extType,ccSettingsChecksum)


    ccLibFullPath='';
    if(nargin<3)


        ccSettingsChecksum=cgxeprivate('computeCCChecksumFromModel',modelName);
    end
    if isempty(ccSettingsChecksum)
        return;
    end
    rootDir=cgxeprivate('get_cgxe_proj_root');
    ccLibName=CGXE.CustomCode.getCustomCodeLibFullName(ccSettingsChecksum,extType);
    ccLibFullPath=fullfile(rootDir,'slprj','_slcc',ccSettingsChecksum,ccLibName);

end