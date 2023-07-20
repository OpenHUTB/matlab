function refreshLogArea(h)




    if~h.closed&&~isempty(h.dialogH)&&...
        isa(h.dialogH,'DAStudio.Dialog')
        try
            h.dialogH.refresh();
        catch Mex %#ok<NASGU>
        end
    end
end

