function resp=isExeProject(h)




    exeBuildActions={'Create_project','Build','Build_and_execute'};

    resp=any(strcmpi(exeBuildActions,h.BuildAction));