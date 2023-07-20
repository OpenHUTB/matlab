function isa=isTextScalar(text)


    isa=true;
    try
        mustBeTextScalar(text);
    catch
        isa=false;
    end

end
