


function b=hasLabel(rootFolder,filepath,category,label)




    proj=alm.internal.project.getProject(rootFolder);

    b=false;

    if isempty(category)||isempty(label)
        return;
    end

    fileObj=proj.findFile(filepath);
    if~isempty(fileObj)
        labelObjs=fileObj.Labels;
        if~isempty(labelObjs)
            lgx=strcmp({labelObjs.CategoryName},category);
            labelObjs=labelObjs(lgx);
            if~isempty(labelObjs)
                b=any(strcmp({labelObjs.Name},label));
            end
        end
    end

end
