function[flag,rootDir]=isGpuCoderDLTargetsInstalled



    crumbFile='dltargets.gpucoder_dl_targets_spkg_crumb';
    fullPath=which(crumbFile);

    if(isempty(fullPath))
        flag=false;
        rootDir='';
    else
        flag=true;
        rootDir=dltargets.gpucoder_dl_targets_spkg_crumb;
    end

end
