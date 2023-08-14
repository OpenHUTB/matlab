function memmap=createAutoMemoryMap(varargin)

    mdl=varargin{1};
    cs=getActiveConfigSet(mdl);


    mmc=soc.memmap.MemoryMapInfo(cs);

    mmc.scrapeModel(mdl);
    mmc.genAutoMap;
    mmc.writeToModelWorkspace;

    memmap=mmc.mmap;

end
