function flag=getFlag(obj,mdl,studio)


    flag=[];
    list=get_param(mdl,'CodePerspectiveFlags');
    if~iscell(list)
        list={};
    end
    for i=1:length(list)
        f=list{i};
        if f.studio==studio
            flag=f;
            return;
        end
    end
