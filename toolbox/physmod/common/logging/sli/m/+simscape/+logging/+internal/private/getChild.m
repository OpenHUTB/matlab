function n=getChild(obj,nameOrIndex)





    if isnumeric(nameOrIndex)
        n=obj(nameOrIndex);
    else
        try
            n=obj.(nameOrIndex);
        catch
            n=node(obj,nameOrIndex);
        end
    end
end