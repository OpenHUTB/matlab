function val=baseValidateGetPropValue(this,pvpairs,prop)%#ok<INUSL>






    prop_idx=strmatch({pvpairs{1:2:end}},prop);%#ok<CCAT1>
    if isempty(prop_idx)
        val=[];
    else
        val=pvpairs{2*prop_idx};
    end

end

