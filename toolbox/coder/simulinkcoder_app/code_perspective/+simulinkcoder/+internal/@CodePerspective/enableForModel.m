function enableForModel(obj,mdl,bool)


    list=obj.getPerModelInstances(mdl);
    for i=1:length(list)
        a=list{i};
        a.active=bool;
    end

