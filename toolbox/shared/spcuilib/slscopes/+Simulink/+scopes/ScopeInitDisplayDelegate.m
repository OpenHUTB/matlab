function ScopeInitDisplayDelegate




    if~usejava('jvm')
        return;
    end

    meta.class.fromName('uiservices.GraphicalPropertyEditor');
