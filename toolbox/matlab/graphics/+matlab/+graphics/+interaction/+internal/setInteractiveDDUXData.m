function setInteractiveDDUXData(~,interaction,method)




    if ischar(interaction)&&ischar(method)
        try
            builtin('_logddux','interactions','interactionType',interaction,'method',method);
        catch
        end
    end
