function this=ModelFilePrefs
















    mlock;

    persistent root_instance


    if~isa(root_instance,'Simulink.ModelFilePrefs')
        this=Simulink.ModelFilePrefs;
        root_instance=this;
    else
        this=root_instance;
    end
