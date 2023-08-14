function isValid=isValidControlVariableValue(value)






    isValid=~isempty(value)&&((isnumeric(value)&&all(isfinite(value)))||...
    islogical(value)||isa(value,'Simulink.Parameter')||isa(value,'Simulink.VariantControl'));
end
