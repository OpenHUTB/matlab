


function childModelDir=ChildModelFolder(aObj,aChildModel)



    childModelDir='';
    slprjdir=aObj.SlprjFolder();
    if~isempty(slprjdir)
        if~aObj.getGenerateCode()...
            &&strcmpi(aObj.getCodePlacement(),aObj.cFlatPlacement)
            childModelDir=slprjdir;
        else
            childModelDir=...
            [slprjdir,filesep,aObj.getTargetName(),filesep,aChildModel];
        end
    end
    if~isdir(childModelDir)
        childModelDir='';
    end
end

