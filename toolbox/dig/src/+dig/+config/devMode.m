



function oldDevMode=devMode(configname,mode)
    model=dig.config.Model.getOrCreate(configname);

    oldDevMode=model.getDevMode();

    if(nargin==2)
        model.setDevMode(mode);
    end
end