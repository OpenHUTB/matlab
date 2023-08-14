function sysCompHdl=simulinkElemToArchElem(slHdl)






    sysCompImpHdl=systemcomposer.utils.getArchitecturePeer(slHdl);
    sysCompHdl=systemcomposer.arch.Element.getObjFromImpl(sysCompImpHdl,'');
end
