function value=double(unsafeValue)
    if isnumeric(unsafeValue)
        value=double(unsafeValue);
    else
        value=NaN;
    end
end