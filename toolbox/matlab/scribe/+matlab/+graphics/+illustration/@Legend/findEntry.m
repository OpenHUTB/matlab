function varargout=findEntry(hObj,hLookupObj)

    varargout{1}=matlab.graphics.illustration.legend.LegendEntry.empty;
    entries=getEntries(hObj);


    if isa(hLookupObj,'matlab.graphics.illustration.legend.LegendIcon')
        for k=1:numel(entries)
            if entries(k).Icon==hLookupObj
                varargout{1}=entries(k);
                break;
            end
        end

    elseif isa(hLookupObj,'matlab.graphics.primitive.Text')
        for k=1:numel(entries)
            if entries(k).Label.TextComp==hLookupObj
                varargout{1}=entries(k);
                break;
            end
        end

    elseif isa(hLookupObj,'matlab.graphics.illustration.legend.Text')
        for k=1:numel(entries)
            if entries(k).Label==hLookupObj
                varargout{1}=entries(k);
                break;
            end
        end

    else






        for k=1:numel(entries)
            if entries(k).Object==hLookupObj
                varargout{1}=entries(k);
                break;
            end
        end
    end

