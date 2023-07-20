function filterApplied=getFilterApplied(rootId)




    filterApplied=[];
    roots=cv('RootsIn',cv('get',rootId,'.modelcov'));
    for idx=1:numel(roots)
        filterApplied=cv('get',roots(idx),'.filterApplied');
        if~isempty(filterApplied)
            return;
        end
    end
end
