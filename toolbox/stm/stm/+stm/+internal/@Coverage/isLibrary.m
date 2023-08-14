

function bool=isLibrary(model)
    try
        bool=bdIsLibrary(model);
    catch
        bool=false;
    end
end