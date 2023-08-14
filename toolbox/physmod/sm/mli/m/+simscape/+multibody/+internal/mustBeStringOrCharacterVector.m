function mustBeStringOrCharacterVector(input)







    if~((isstring(input)&&isscalar(input))||...
        (ischar(input)&&ismatrix(input)&&size(input,1)==1))
        error('Input must be a scalar string or character (row) vector.');
    end
end


