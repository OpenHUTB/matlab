function removeFlag(obj,mdl,studio)


    obj.cleanupFlags(mdl);
    list=get_param(mdl,'CodePerspectiveFlags');


    flags={};
    for i=1:length(list)
        f=list{i};
        if f.studio~=studio
            flags{end+1}=f;%#ok<AGROW>
        else
            delete(f);
        end
    end

    set_param(mdl,'CodePerspectiveFlags',flags);


