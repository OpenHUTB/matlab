function out=getPaneDisplayName(obj,englishName)






    try
        out=obj.getPaneDisplayPath(obj.EnglishNameMap(englishName));
    catch me
        if me.identifier=="MATLAB:Containers:Map:NoKey"
            out=englishName;
        else
            rethrow(me);
        end
    end
