function storeLibraryUpgradesInTmpFiles(file,libraryLinksTracker)










    import com.mathworks.toolbox.slprojectsimulink.upgrade.LibraryLinksTracker;
    import com.mathworks.toolbox.slprojectsimulink.upgrade.LibraryLink;
    import com.mathworks.toolbox.slprojectsimulink.upgrade.Block;
    import Simulink.ModelManagement.Project.Upgrade.Utils.javaCollectionToCellArray;
    import Simulink.ModelManagement.Project.Upgrade.Utils.isLibraryLinkModified;
    import Simulink.ModelManagement.Project.Upgrade.Utils.getNameForVersion;

    path=char(file);
    [~,model]=fileparts(path);
    jLinks=libraryLinksTracker.getDisabledLibraryLinks(file);
    iterator=jLinks.iterator;

    while(iterator.hasNext)
        jLink=iterator.next;
        link=char(jLink.getModelBlock().getBlock());
        if~isLibraryLinkModified(link)
            continue
        end
        refBlock=char(jLink.getLibraryBlock().getBlock());
        libraryFile=jLink.getLibraryBlock().getSystem();
        [~,library]=fileparts(char(libraryFile));
        try
            tmpLibraryFile=libraryLinksTracker.getTemporaryFileFor(libraryFile);
            [~,tmpLibrary]=fileparts(char(tmpLibraryFile));
            if~bdIsLoaded(tmpLibrary)
                load_system(char(tmpLibraryFile.getPath));
            end
            upgradedBlock=getNameForVersion(tmpLibrary,refBlock,model);


            set_param(tmpLibrary,'Lock','off');


            add_block(link,upgradedBlock);






            try
                state=warning('off');
                restoreWarning=onCleanup(@()warning(state));
                save_system(tmpLibrary);
                libraryLinksTracker.recordBlockUpgradeRequest(...
                jLink,Block(tmpLibraryFile,upgradedBlock));
            catch E
                errorMessage=...
                getString(message('SimulinkProject:Upgrade:tmpLibraryError',...
                library,refBlock,model,E.message));
                libraryLinksTracker.logErrorsFor(libraryFile,errorMessage);
            end
        catch E
            errorMessage=...
            getString(message('SimulinkProject:Upgrade:tmpLibraryError',...
            library,refBlock,model,E.message));
            libraryLinksTracker.logErrorsFor(libraryFile,errorMessage);
        end

    end
end

