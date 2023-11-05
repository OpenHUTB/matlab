function varargout=getDescriptiveLabelForDisplay(hobj)

    if~isempty(hobj.Tag)
        varargout{1}=hobj.Tag;
    else
        varargout{1}=hobj.DisplayName;
    end
end