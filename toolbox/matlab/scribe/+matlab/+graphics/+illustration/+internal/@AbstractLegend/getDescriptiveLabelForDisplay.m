function varargout=getDescriptiveLabelForDisplay(hobj)










    t=hobj.Title_I;
    tf=~isempty(t)&&isvalid(t)&&(~isempty(t.String)||strcmp(t.TextComp.Editing_I,'on'));

    varargout{1}='';
    if strcmp(hobj.TagMode,'manual')&&~isempty(hobj.Tag)
        varargout{1}=hobj.Tag;
    elseif tf
        varargout{1}=hobj.Title.String;
    end
end
