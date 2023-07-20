function flag=isBuildProject(h)




    flag=strcmpi(h.BuildAction,'Build')||...
    strcmpi(h.BuildAction,'Build_and_execute')||...
    strcmpi(h.BuildAction,'Archive_library');