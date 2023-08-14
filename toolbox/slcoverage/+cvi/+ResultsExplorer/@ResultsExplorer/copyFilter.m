function copyFilter(obj,nodes)




    filterName='';


    for idx=1:numel(nodes)
        n=nodes{idx};
        cvd=n.data.getCvd();
        if isempty(cvd.filter)
            return;
        end
        if isempty(filterName)
            filterName=cvd.filter;
        elseif~strcmpi(filterName,cvd.filter)
            return;
        end
    end
    obj.filterEditor.filterName=filterName;
end