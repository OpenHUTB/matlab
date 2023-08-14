function yes=isScalarText(arg)



    yes=(ischar(arg)&&isrow(arg))||(isstring(arg)&&isscalar(arg));
end