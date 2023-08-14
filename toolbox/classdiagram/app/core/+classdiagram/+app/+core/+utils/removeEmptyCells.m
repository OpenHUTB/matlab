function cellarr=removeEmptyCells(cellarr)
    if isempty(cellarr)
        cellarr={};
        return;
    end
    idx=cellfun('isempty',cellarr);
    cellarr(idx)=[];
end