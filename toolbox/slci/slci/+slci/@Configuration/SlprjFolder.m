


function slprjDir=SlprjFolder(aObj)



    if~aObj.getGenerateCode()...
        &&strcmpi(aObj.getCodePlacement(),aObj.cFlatPlacement)
        slprjDir=aObj.getDerivedCodeFolder();
    else
        if aObj.getTopModel
            slprjDir=...
            fullfile(fileparts(aObj.getDerivedCodeFolder()),'slprj');
        else
            slprjDir=fileparts(fileparts(aObj.getDerivedCodeFolder()));
        end
    end
    if~isdir(slprjDir)
        slprjDir='';
    end
end

