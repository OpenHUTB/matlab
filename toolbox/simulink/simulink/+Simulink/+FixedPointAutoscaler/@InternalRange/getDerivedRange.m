function derivedRange=getDerivedRange(obj)






    result=findResultForBlockFromArrayOrCreate(obj.runObj,obj.blockObject);

    if isempty(result.DerivedMin)
        min=-Inf;
    else
        min=result.DerivedMin;
    end

    if isempty(result.DerivedMax)
        max=Inf;
    else
        max=result.DerivedMax;
    end

    derivedRange=[min,max];
