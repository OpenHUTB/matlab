function bfi=getBaseFileInfoForFile(obj,fileName)






    allBfi=obj.Infos;

    bfiIdx=strcmp({allBfi.File},fileName);

    if bfiIdx<1
        bfi=obj.createEmptyTypeVector;
    else
        bfi=allBfi(bfiIdx);
    end
end


