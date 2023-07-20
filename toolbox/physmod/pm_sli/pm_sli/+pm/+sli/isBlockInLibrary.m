function result=isBlockInLibrary(block)








    blockDiagram=pmsl_bdroot(block);
    result=strcmp(get_param(blockDiagram,'BlockDiagramType'),'library');

end