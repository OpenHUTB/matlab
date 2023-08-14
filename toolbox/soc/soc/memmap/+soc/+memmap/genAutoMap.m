function mmap=genAutoMap(mdl)

    cs=getActiveConfigSet(mdl);
    mmc=soc.memmap.MemoryMapInfo(cs);
    mmc.scrapeModel(mdl);
    mmc.genAutoMap;
    mmap=mmc.mmap;

end