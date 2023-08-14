function saveBDCopies(rMgr)
...
...
...
...
...
...
    try
        saveAllBDs(rMgr);
    catch ex
        Simulink.variant.reducer.utils.logException(ex);
        rMgr.Error=ex;
    end
end

function saveAllBDs(rMgr)
...
...
...
...
...
...
...
...

    levelKeys=rMgr.RedBDLevelMap.keys;
    for lvlIdx=numel(levelKeys):-1:1
        key=levelKeys{lvlIdx};
        bds=rMgr.RedBDLevelMap(key);
        saveBDs(rMgr,bds);
    end




    topMdl=rMgr.getOptions().TopModelName;
    refreshMdlBlksInBD(topMdl);
end

function refreshMdlBlksInBD(bd)
...
...
...
...
    try
        obj=get_param(bd,'Object');
        obj.refreshModelBlocks();
    catch ex
        Simulink.variant.reducer.utils.logException(ex);


    end
end

function clearForwardingTable(libName)










    set_param(libName,'ForwardingTable',{});
end

function saveBDs(rMgr,bds)
...
...
...
...
...
...


    for bdIdx=1:numel(bds)
        bd=bds{bdIdx};
        if isKey(rMgr.RedundantSRFiles,bd)
            continue;
        end
        if bdIsLibrary(bd)
            clearForwardingTable(bd);
        end
        refreshMdlBlksInBD(bd);
        save_system(bd,bd,'SaveDirtyReferencedModels','on');



    end
end


