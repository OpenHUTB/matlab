function view(slddName)





    try
        simulinkcoder.internal.app.ViewSDP(slddName);
    catch e
        throwAsCaller(e);
    end
end
