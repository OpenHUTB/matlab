


function labels=getLabelsForCategory(rootFolder,category)

    labels={};

    if isempty(category)
        return;
    end


    proj=alm.internal.project.getProject(rootFolder);


    catObj=proj.findCategory(category);


    if~isempty(catObj)
        if~isempty(catObj.LabelDefinitions)
            labels={catObj.LabelDefinitions.Name};
        end
    end
end
