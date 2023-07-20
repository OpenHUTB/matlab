function isa=isText(text)


    isa=true;
    try
        mustBeText(text);
    catch
        isa=false;
    end

end
