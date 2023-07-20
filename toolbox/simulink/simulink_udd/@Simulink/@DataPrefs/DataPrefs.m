function this=DataPrefs


















    mlock;

    persistent root_instance


    if~isa(root_instance,'Simulink.DataPrefs'),
        this=Simulink.DataPrefs;
        root_instance=this;
    else
        this=root_instance;
    end
