function varargout=getDescriptiveLabelForDisplay(hobj)









    if strcmp(hobj.TagMode,'manual')&&~isempty(hobj.Tag)
        varargout{1}=hobj.Tag;
    else
        varargout{1}=hobj.Label.String;
    end
end