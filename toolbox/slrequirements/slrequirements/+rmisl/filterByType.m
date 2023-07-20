function objList=filterByType(objList,objTypeFilters)



    if nargin<2
        objTypeFilters=rmi.settings_mgr('get','coverageSettings','objTypeFilters');
    end

    isFiltered=false(size(objList));
    for i=1:length(objList)
        if iscell(objList)
            obj=get_param(objList{i},'Object');
        else
            obj=get_param(objList(i),'Object');
        end
        isFiltered(i)=any(strcmp(class(obj),objTypeFilters));
    end

    if any(isFiltered)
        objList(isFiltered)=[];
    end
end
