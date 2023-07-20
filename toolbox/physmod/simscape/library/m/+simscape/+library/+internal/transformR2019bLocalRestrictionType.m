function out=transformR2019bLocalRestrictionType(in)






    out=in;


    if isempty(getValue(in,'restriction_type'))
        out=setValue(out,'restriction_type','foundation.enum.restriction_type.fixed');
    end

end