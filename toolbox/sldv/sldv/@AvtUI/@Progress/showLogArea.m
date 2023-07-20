function showLogArea(h)




    if~h.closed&&~isempty(h.dialogH)&&...
        isa(h.dialogH,'DAStudio.Dialog')
        try
            h.dialogH.show();
        catch Mex %#ok<NASGU>
        end
    end
end

