function element=top(obj)




    if obj.isempty
        element=obj.Data;
    else
        element=obj.Data(end);
    end
end
