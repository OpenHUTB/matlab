function obj=getInstance(create)


















    mlock;

    persistent singleton;

    obj=singleton;

    prefs_exist=isa(singleton,'Simulink.Preferences');

    if~prefs_exist
        if~nargin||create

            obj=Simulink.Preferences;
            singleton=obj;
            child=Simulink.GeneralPrefs;
            child.connect(obj,'up');
            child=Simulink.EditorPrefs;
            child.connect(obj,'up');
            child=Simulink.ModelFilePrefs;
            child.connect(obj,'up');
            prefs_exist=true;



            s=matlab.settings.internal.settings;
            if~s.hasGroup('Simulink')
                obj.Save();
            end
        end
    end

    if~prefs_exist
        obj=[];
        return;
    end



    p=obj.find('-isa','Simulink.DataPrefs');

