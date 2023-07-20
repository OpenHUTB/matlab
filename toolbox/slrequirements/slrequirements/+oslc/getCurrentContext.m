function[currentContext,currentName]=getCurrentContext()


    currentContext=[];

    currentName=oslc.Project.currentProject();
    if isempty(currentName)
        currentName=getString(message('Slvnv:oslc:MatlabSaysProjectNotSelected'));
        return;
    end

    currentProj=oslc.Project.get(currentName);
    if isempty(currentProj)
        currentName=getString(message('Slvnv:oslc:MatlabSaysFailedToFindProject',currentName));
    else
        currentContext=currentProj.getContext();
    end
end

