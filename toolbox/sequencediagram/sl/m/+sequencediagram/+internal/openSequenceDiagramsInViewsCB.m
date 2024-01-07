function openSequenceDiagramsInViewsCB(cbinfo)
    bdH=cbinfo.studio.App.blockDiagramHandle;
    zcModel=systemcomposer.arch.Model(bdH);
    zcModel.openViews;

end


