function updateBdListener(obj,mdl)


    flag='CodePerspectiveFlags';
    data='CodePerspectiveData';

    flags=get_param(mdl,flag);
    dataList=get_param(mdl,data);
    if isempty(flags)
        set_param(mdl,data,[]);
    else
        if isempty(dataList)
            bd=get_param(mdl,'Object');
            cpl=simulinkcoder.internal.CodePerspectiveListener(bd);
            set_param(mdl,data,cpl);
        end
    end

