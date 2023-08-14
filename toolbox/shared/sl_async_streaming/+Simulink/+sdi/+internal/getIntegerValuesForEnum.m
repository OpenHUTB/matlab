function ret=getIntegerValuesForEnum(vals,baseType)





    try
        ret=eval(sprintf('%s(vals)',baseType));
        return
    catch me %#ok<NASGU>
        ret=ones(size(vals),baseType);
    end


    ev=enumeration(vals);
    for idx=1:numel(vals)
        curVal=find(ev==vals(idx));%#ok<NASGU>
        ret(idx)=eval(sprintf('%s(curVal)',baseType));
    end
end