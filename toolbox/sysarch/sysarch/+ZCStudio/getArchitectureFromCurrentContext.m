function topArchMdl=getArchitectureFromCurrentContext(cbinfo)




    hdlCurrentArchElem=SLStudio.Utils.getDiagramHandle(cbinfo);
    currentArchElem=systemcomposer.utils.getArchitecturePeer(hdlCurrentArchElem);
    topArchMdl=currentArchElem.getTopLevelArchitecture;

end