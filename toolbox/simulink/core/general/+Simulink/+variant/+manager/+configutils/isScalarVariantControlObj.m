function is=isScalarVariantControlObj(d)






    is=~isempty(d)&&isscalar(d)&&...
    isa(d,'Simulink.VariantControl');
end
