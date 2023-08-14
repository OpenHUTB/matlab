function out=getDescription(obj)


    if isempty(obj.Description)
        default=obj.Name;

        if isempty(obj.UI)
            out=default;
        else
            if isempty(obj.UI.searchPrompt)
                out=default;
            else
                try
                    out=message(obj.UI.searchPrompt).getString;
                catch
                    out=default;
                end
            end
        end
        obj.Description=out;
    else
        out=obj.Description;
    end

