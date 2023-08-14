function blkInfoMap=getLibraryTree()




    persistent LibraryTree

    if isempty(LibraryTree)
        compNodeBldr=pm.util.CompoundNodeBuilder(...
        @simmechanics.sli.internal.library_node_builder);
        simpleNodeBldr=pm.util.SimpleNodeBuilder(...
        @simmechanics.sli.internal.block_node_builder);

        dirTreeBldr=pm.util.DirTreeBuilder(compNodeBldr,simpleNodeBldr);

        smBase=fullfile(matlabroot,'toolbox','physmod','sm');
        libDir=fullfile(smBase,'sli','m','+simmechanics','+library');
        LibraryTree=dirTreeBldr.buildTree(libDir);

    end

    blkInfoMap=LibraryTree;
    mlock;
end