function pushUpgrades(blocksUpgradesMap)



    if blocksUpgradesMap.isEmpty
        return
    end

    import com.mathworks.toolbox.slprojectsimulink.upgrade.Block;

    entries=blocksUpgradesMap.entrySet;
    iterator=entries.iterator;

    while iterator.hasNext
        entry=iterator.next;
        jBlockLibrary=entry.getKey;
        jBlockUpgrade=entry.getValue;
        libraryPath=char(jBlockLibrary.getSystem());
        [~,library]=fileparts(libraryPath);

        sourceLibraryPath=char(jBlockUpgrade.getSystem);
        [~,sourceLibrary]=fileparts(sourceLibraryPath);

        i_loadIfNecessary(library,libraryPath);
        i_loadIfNecessary(sourceLibrary,sourceLibraryPath);


        set_param(library,'Lock','off');

        block=char(jBlockLibrary.getBlock());
        upgradedBlock=char(jBlockUpgrade.getBlock());
        i_replace_block(block,upgradedBlock);
    end

    save_system(library);
end

function i_loadIfNecessary(system,systemPath)
    if~bdIsLoaded(system)
        load_system(systemPath);
    end
end

function i_replace_block(oldBlock,newBlock)
    import Simulink.ModelManagement.Project.Upgrade.Utils.removeOuterMask;
    import Simulink.ModelManagement.Project.Upgrade.Utils.getDecorationParams;
    removeOuterMask(newBlock,oldBlock);
    decorations=getDecorationParams(oldBlock);

    oldBlockHandle=getSimulinkBlockHandle(oldBlock);
    delete_block(oldBlockHandle);
    add_block(newBlock,oldBlock,decorations{:});
    set_param(oldBlock,'LinkStatus','none');

end