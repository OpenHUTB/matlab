function mustBeCharVectorOrString(c,quantityName)










    if~(isempty(c)||(ischar(c)&&isrow(c))||...
        (isstring(c)&&isscalar(c)))
        throwAsCaller(MException(message('shared_adlib:mustBeCharVectorOrString:InvalidValue',quantityName)));
    end
