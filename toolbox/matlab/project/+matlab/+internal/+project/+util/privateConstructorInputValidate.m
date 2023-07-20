function privateConstructorInputValidate(input,inputType)



    if~isa(input,inputType)
        error(message('MATLAB:project:api:PrivateConstructor'));
    end

end