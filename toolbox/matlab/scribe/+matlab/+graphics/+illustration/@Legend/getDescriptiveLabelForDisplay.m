function varargout=getDescriptiveLabelForDisplay(hobj)









    if strcmp(hobj.TagMode,'manual')&&~isempty(hobj.Tag)
        varargout{1}=hobj.Tag;
    elseif doMethod(hobj,'hasTitle');
        varargout{1}=hobj.Title.String;
    else
        str=hobj.String;
        for i=1:numel(str)
            if iscell(str{i})
                str{i}=strjoin(str{i},'\n');
            end
        end
        varargout{1}=str;
    end
end
