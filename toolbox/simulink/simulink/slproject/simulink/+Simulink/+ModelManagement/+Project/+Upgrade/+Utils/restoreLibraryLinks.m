function restoreLibraryLinks(file,libraryLinksTracker)
    import com.mathworks.toolbox.slprojectsimulink.upgrade.LibraryLinksTracker;
    import Simulink.ModelManagement.Project.Upgrade.Utils.javaCollectionToCellArray;

    path=char(file);
    [~,model]=fileparts(path);

    if~bdIsLoaded(model)
        load_system(path);
    end

    links=javaCollectionToCellArray(libraryLinksTracker.getLinksToRestore(file));


    for n=1:numel(links)
        set_param(links{n},'LinkStatus','restore');
    end

    if bdIsDirty(model)
        try
            state=warning('off');
            restoreWarning=onCleanup(@()warning(state));
            save_system(model);
        catch


        end
    end
end