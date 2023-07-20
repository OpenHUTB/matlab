function propVal=getParent(obj)
    if isscalar(obj)
        propVal=obj.MesherStruct.Parent;
    else
        propVal=obj(1).MesherStruct.Parent;
    end
end