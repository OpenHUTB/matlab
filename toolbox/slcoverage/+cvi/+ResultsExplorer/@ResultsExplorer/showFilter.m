function showFilter(obj,forCode,filterId)




    if nargin<2
        forCode=false;
        filterId='';
    end

    if~isempty(filterId)
        fi=strfind(filterId,'#');
        filterId=filterId(fi(2)+1:end);
    end
    obj.filterExplorer.showFilter(filterId,forCode);
    obj.explorer.show;
end