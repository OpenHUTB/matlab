function ComputeDerivedCodeFolder(aObj)




    if aObj.getGenerateCode()||...
        ~strcmpi(aObj.getCodePlacement(),aObj.cFlatPlacement)
        BuildDirInfo=RTW.getBuildDir(aObj.getModelName());
        if~aObj.getTopModel
            aObj.fDerivedCodeFolder=[BuildDirInfo.CodeGenFolder,filesep,BuildDirInfo.ModelRefRelativeBuildDir];
        else
            aObj.fDerivedCodeFolder=[BuildDirInfo.CodeGenFolder,filesep,BuildDirInfo.RelativeBuildDir];
        end
    else
        aObj.fDerivedCodeFolder=aObj.getCodeFolder();
    end
end

