function this=GeneralPrefs(bdhandle)
















    mlock;

    persistent root_instance


    if~isa(root_instance,'Simulink.GeneralPrefs')
        this=Simulink.GeneralPrefs;
        root_instance=this;
    else
        this=root_instance;
    end
