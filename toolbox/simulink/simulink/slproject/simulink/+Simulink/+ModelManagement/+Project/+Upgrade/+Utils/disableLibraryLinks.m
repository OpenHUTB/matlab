function disabledLinks=disableLibraryLinks(file,linksToDisable)
    import com.mathworks.toolbox.slprojectsimulink.upgrade.LibraryLinksTracker;
    import com.mathworks.toolbox.slprojectsimulink.upgrade.Block;

    path=char(file);
    [~,model]=fileparts(path);

    if~bdIsLoaded(model)
        load_system(path);
    end

    if strcmp(get_param(model,'LockLinksToLibrary'),'on')
        set_param(model,'LockLinksToLibrary','off');
    end

    disabledLinks=java.util.HashSet;
    iterator=linksToDisable.iterator();

    while iterator.hasNext()
        jLink=iterator.next();
        link=char(jLink.getBlock());
        if get_param(link,"LinkStatus")~="unresolved"&&get_param(link,"BlockType")~="SimscapeBlock"
            set_param(link,LinkStatus="inactive");
            disabledLinks.add(jLink);
        end
    end
end