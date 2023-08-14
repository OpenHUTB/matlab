function isLib=isLibraryBlock(this,hBlock)





    isLib=strcmp(get_param(pmsl_bdroot(objectToHandle(hBlock)),'BlockDiagramType'),'library');



