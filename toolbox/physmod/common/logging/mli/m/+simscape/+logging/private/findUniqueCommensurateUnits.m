function units=findUniqueCommensurateUnits(units)




    if~iscell(units)
        units={units};
    end
    c=pm_commensurate(units,units);
    c=triu(c);
    keep=false(1,numel(units));
    for idx=1:numel(units)
        col=c(:,idx);
        keep(idx)=~any(find(col)<idx);
    end
    units=units(keep);
end

