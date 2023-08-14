function blkdgm=getBdRoot(h)




    if isempty(h.hParent)||~h.hParent.isValid
        blkdgm=h.Name;
    else
        blkdgm=h.hParent.getBdRoot;
    end

end

