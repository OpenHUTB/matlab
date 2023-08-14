function createComponent(configName,compName,varargin)
    p=inputParser();
    p.addParameter('Location',pwd);
    p.addParameter('Persist',true);
    p.parse(varargin{:});





    model=dig.config.Model.getOrCreate(configName);
    try
        editor=model.openEditor();
        editor.createComponent(compName,p.Results.Location);
        editor.updateModel();
    catch ME
        if~strcmp(ME.identifier,'dig:config:resources:ConfigHasComponent')
            editor.destroyComponent(compName);
        end
        editor.updateModel();
        model.closeEditor();
        if isCausedByFileAccessError(ME)
            throw(ME.cause{1});
        else
            rethrow(ME);
        end
    end

    try
        editor.save();
        model.closeEditor();
        if p.Results.Persist
            model.Preferences.rememberPath(p.Results.Location);
            model.savePreferences();
        end
    catch SE
        editor.destroyComponent(compName);
        editor.updateModel();
        model.closeEditor();
        throw(MException(message('dig:config:resources:FileAccessError',p.Results.Location)));
    end
end

function result=isCausedByFileAccessError(me)
    result=false;
    if length(me.cause)==1
        cause=me.cause{1};
        if strcmp(cause.identifier,'dig:config:resources:FileAccessError')
            result=true;
        end
    end
end
