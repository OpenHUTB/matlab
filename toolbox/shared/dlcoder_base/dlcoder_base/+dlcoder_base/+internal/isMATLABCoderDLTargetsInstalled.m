function[flag,rootDir]=isMATLABCoderDLTargetsInstalled






    crumbFile='dltargets.matlabcoder_dl_targets_spkg_crumb';
    fullPath=which(crumbFile);

    if(isempty(fullPath))
        flag=false;
        rootDir='';
    else
        flag=true;
        rootDir=dltargets.matlabcoder_dl_targets_spkg_crumb;
    end

end
