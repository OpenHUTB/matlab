function tf=isInteractivityEnabled(obj)

    try
        tf=strcmpi(obj.InteractionContainer.Enabled,'on');
    catch
        tf=strcmpi(obj.Interactions.Enabled,'on');
    end

