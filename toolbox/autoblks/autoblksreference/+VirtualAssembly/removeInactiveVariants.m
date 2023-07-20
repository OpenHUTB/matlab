


function coudntDelete=removeInactiveVariants(mainMdl,newMDLname,testplan)


    load_system(mainMdl);
    name=mainMdl;
    coudntDelete={};
    f=Simulink.FindOptions;
    f=Simulink.FindOptions('Variants','AllVariants');
    bh=Simulink.findBlocks(name,f);
    allblocks=getfullname(bh);

    f=Simulink.FindOptions;
    f=Simulink.FindOptions('Variants','ActiveVariants');
    bh2=Simulink.findBlocks(name,f);
    ToKeep=getfullname(bh2);

    if~isempty(testplan)
        for i=1:size(testplan,1)
            blks=VirtualAssembly.addTestScenario(testplan{i});
            ToKeep=[ToKeep;blks];
        end
    end


    ToDelete=setdiff(allblocks,ToKeep);

    ToDelete=setxor(ToDelete,name);
    pp=1;

    for ii=1:numel(ToDelete)
        try
            delete_block(ToDelete{ii})
        catch
            coudntDelete{pp}=ToDelete{ii};
            pp=pp+1;
        end
    end
    openmdl=[pwd,'/VirtualVehicleConfigRef'];
    tf=slreportgen.utils.isModelLoaded('VirtualVehicleConfigRef');

    if tf
        close_system('VirtualVehicleConfigRef');
    end
    save_system(mainMdl,newMDLname,'OverwriteIfChangedOnDisk',true,'SaveDirtyReferencedModels',true);
end