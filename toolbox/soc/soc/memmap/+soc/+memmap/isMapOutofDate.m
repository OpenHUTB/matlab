function[status,newmap]=isMapOutofDate(map,mdl)

    newmap=soc.memmap.createAutoMemoryMap(mdl);
    status=~isequal(map,newmap);
end

