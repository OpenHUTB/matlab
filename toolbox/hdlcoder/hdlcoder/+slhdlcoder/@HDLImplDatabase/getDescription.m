function value=getDescription(this,tag)






    try
        value=this.DescriptionDB(tag);
    catch me
        if~strcmp(me.identifier,'MATLAB:Containers:Map:NoKey')
            rethrow(me);
        end
        value=[];
    end
