function varargout=getEntries(hObj)

    varargout{1}=flipud(hObj.EntryContainer.Children);
