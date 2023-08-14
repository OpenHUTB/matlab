function res=isAnyNumericType(u)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always')

    res=~isempty(u)&&(isnumerictype(u)||isa(u,'Simulink.NumericType'));
end
