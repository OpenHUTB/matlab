function ret=getRegisteredFileImporters(this)
    ret=string.empty;
    sz=this.CustomParsers.getCount;
    for idx=1:sz
        importers=this.CustomParsers.getDataByIndex(idx);
        for idx2=1:numel(importers)
            ret(end+1)=string(class(importers{idx2}));%#ok<AGROW>
        end
    end
    ret=unique(ret);
end
