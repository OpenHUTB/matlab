function out=getData(obj,paramOrName)


    adp=obj.Source;

    if ischar(paramOrName)
        name=configset.internal.util.toShortName(paramOrName);
        p=adp.getParamData(name);
    else
        p=paramOrName;
    end


    if isempty(p)
        out=adp.getParamStructNoData(name);
    else





        if p.Hidden&&isempty(p.Children)
            out=[];
        else
            out=adp.getParamStruct(p);
        end
    end

end


