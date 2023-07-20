function bdnames=getBlockDiagramNames



    bdnames=getfullname(Simulink.allBlockDiagrams);
    bdnames=cellstr(bdnames);
