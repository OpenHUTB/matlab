function resetConfig()




    im=slCreateInterfaceManager;
    im.reset();

    icons=DAStudio.IconManager;
    icons.clear();

    c=dig.Configuration.get();
    if~isempty(c)
        c.unload();
    end
end
