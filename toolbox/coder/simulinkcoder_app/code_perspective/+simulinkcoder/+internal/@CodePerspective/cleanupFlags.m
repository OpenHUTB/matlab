function cleanupFlags(obj,mdl)


    list=get_param(mdl,'CodePerspectiveFlags');
    if~iscell(list)
        list={};
    end


    flags={};
    for i=1:length(list)
        f=list{i};
        if f.isvalid
            if f.studio.isvalid
                flags{end+1}=f;%#ok<AGROW>
            else
                delete(f);
            end
        end
    end

    set_param(mdl,'CodePerspectiveFlags',flags);


