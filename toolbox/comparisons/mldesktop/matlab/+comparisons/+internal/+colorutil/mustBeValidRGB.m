function mustBeValidRGB(input)




    if~comparisons.internal.colorutil.isValidRGB(input)
        throwAsCaller(MException(message("comparisons:settings:InvalidColor")));
    end
end