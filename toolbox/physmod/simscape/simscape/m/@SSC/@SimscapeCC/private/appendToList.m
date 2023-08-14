function list=appendToList(list,obj)






    if isempty(list)
        list=obj;
    else
        list(end+1)=obj;
    end

