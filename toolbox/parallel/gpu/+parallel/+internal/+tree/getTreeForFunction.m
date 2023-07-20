function fnode=getTreeForFunction(fname,fcnType,errorMechanism)



    fnode=mtree(fname);
    parallel.internal.tree.sanityCheckTree(fnode,fname,fcnType,errorMechanism);
