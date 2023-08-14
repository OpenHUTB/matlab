function[mdlrefs,liblinks,blockcount]=find_mdlref_blocks(mdlname)







    [mdlrefs,liblinks,blockcount]=slInternal('findMdlRefsAndLibLinks',mdlname);

