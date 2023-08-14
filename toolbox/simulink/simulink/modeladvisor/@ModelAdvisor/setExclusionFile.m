function setExclusionFile(mdlName,filePath)




    if~ischar(mdlName)
        error(message('ModelAdvisor:engine:MdlNameMustBeString'));
    end

    if~ischar(filePath)
        error(message('ModelAdvisor:engine:FilePathMustBeString'));
    end

    r=ModelAdvisor.Root;
    if isempty(r.modelToExclusion)
        r.modelToExclusion=containers.Map;
    end


    r.modelToExclusion(mdlName)=filePath;
