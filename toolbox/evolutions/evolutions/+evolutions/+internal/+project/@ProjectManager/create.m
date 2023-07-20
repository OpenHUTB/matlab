function pi=create(obj,project)




    mfModel=mf.zero.Model;
    data=struct('Project',project,'Name',convertStringsToChars(project.Name));
    pi=evolutions.model.ProjectInfo.createObject(mfModel,data);
    obj.insert(pi);
    obj.MfModels(end+1)=mfModel;
    obj.updateProjectFileListener(pi);
end
