function signalLoggingSelector(model)







    narginchk(1,1);
    try
        SigLogSelector.launch('Create',model);
    catch me
        throwAsCaller(me);
    end

end
