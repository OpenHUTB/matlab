function flag=isNaNOrInf(value)





    flag=any(isnan(value(:)))||any(isinf(value(:)));
end
