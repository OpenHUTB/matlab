function bool=isLibProject(h,modelname)





    cs=getActiveConfigSet(modelname);
    bool=strcmp(get_param(cs,'buildAction'),'Archive_library');
