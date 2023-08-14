function projectInfo=getProjectInfoFromPath(obj,projectPath)





    projectInfo=evolutions.model.AbstractInfo.empty(1,0);
    for idx=1:numel(obj.Infos)
        pi=obj.Infos(idx);
        if(isequal(pi.Project.RootFolder,projectPath))
            projectInfo=pi;
            return;
        end
    end
end


