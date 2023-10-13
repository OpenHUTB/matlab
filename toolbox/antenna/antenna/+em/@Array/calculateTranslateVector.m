function v=calculateTranslateVector(obj)

    if isa(obj,'linearArray')
        v=[-obj.TotalArraySpacing/2,0,0];
    elseif isa(obj,'rectangularArray')
        v=[-obj.TotalArraySpacing(2)/2,obj.TotalArraySpacing(1)/2,0];
    else
        v=[];
    end



























