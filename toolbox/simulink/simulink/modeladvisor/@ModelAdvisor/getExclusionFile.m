function fileName=getExclusionFile(mdlName)




    fileName='';
    if~(ischar(mdlName)||ishandle(mdlName))
        error(message('ModelAdvisor:engine:MdlNameInvalid'));
    end

    if ishandle(mdlName)
        mdlName=getfullname(mdlName);
        mdlName=regexprep(mdlName,sprintf('\n'),' ');
    end
    r=ModelAdvisor.Root;


    if isa(r.modelToExclusion,'containers.Map')&&isKey(r.modelToExclusion,mdlName)
        fileName=r.modelToExclusion(mdlName);
    end

