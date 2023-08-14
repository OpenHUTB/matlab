function hLinkIDE=createLinkToIDE(h,hBoard)





    hLinkIDE=CCSLinkTgtPkg.LinkCCS(hBoard,h.ideObjTimeout,h.ideObjBuildTimeout);
