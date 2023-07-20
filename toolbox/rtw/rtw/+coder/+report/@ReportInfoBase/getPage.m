function out=getPage(obj,name)
    idx=cellfun(@(x)strcmp(x.getClassName,name),obj.Pages);
    if any(idx)
        out=obj.Pages{idx};
    else
        out=[];
    end
end
