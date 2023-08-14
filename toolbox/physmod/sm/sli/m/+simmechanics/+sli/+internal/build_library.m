function libHandle=build_library(rootDir)























    compNodeBldr=pm.util.CompoundNodeBuilder(@simmechanics.sli.internal.library_node_builder);
    simpleNodeBldr=pm.util.SimpleNodeBuilder(@simmechanics.sli.internal.block_node_builder);

    dirTreeBldr=pm.util.DirTreeBuilder(compNodeBldr,simpleNodeBldr);

    libTree=dirTreeBldr.buildTree(rootDir);

    libBuildVis=simmechanics.sli.internal.LibraryBuildingVisitor;

    libTree.accept(libBuildVis);


    libHandle=libBuildVis.SLHandle(libTree.NodeID);
    ftEntries=libBuildVis.ForwardingTableEntries;
    ftValue={};
    for idx=1:length(ftEntries)
        ftValue{idx}=ftEntries(idx).getSlParameterValueEntry;
    end
    if~isempty(ftValue)
        set_param(libHandle,'ForwardingTable',ftValue);
    end


    libLayoutVis=simmechanics.sli.internal.LibraryLayoutVisitor(libBuildVis.SLHandle);

    libTree.accept(libLayoutVis);


    commonSetupVis=simmechanics.sli.internal.CommonSetupVisitor(libBuildVis.SLHandle);
    commonSetupVis.BlockSetupFunction=@simmechanics.sli.internal.common_block_setup;

    libTree.accept(commonSetupVis);
