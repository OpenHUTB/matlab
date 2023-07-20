function insert(obj,ai)




    if~ismember(ai,obj.AllInfos)

        obj.AllInfos(end+1)=ai;
    end