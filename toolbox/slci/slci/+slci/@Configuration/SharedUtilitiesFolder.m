


function sharedUtilsDir=SharedUtilitiesFolder(aObj)



    sharedUtilsDir='';
    slprjdir=aObj.SlprjFolder();
    if~isempty(slprjdir)
        if~aObj.getGenerateCode()...
            &&strcmpi(aObj.getCodePlacement(),aObj.cFlatPlacement)
            sharedUtilsDir=slprjdir;
        else
            sharedUtilsDir=...
            [slprjdir,filesep,aObj.getTargetName(),filesep,'_sharedutils'];
        end
    end
    if~isdir(sharedUtilsDir)
        sharedUtilsDir='';
    end
end


