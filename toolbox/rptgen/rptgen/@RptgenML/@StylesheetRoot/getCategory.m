function returnedValue=getCategory(h,storedValue,id,displayName,isVisible)




    if isempty(storedValue)
        ssLib=h.StylesheetLibrary;
        if isempty(ssLib)
            h.getStylesheetLibrary;
            returnedValue=get(h,['Category',id]);
        else
            returnedValue=RptgenML.LibraryCategory(displayName,...
            'Visible',isVisible,...
            'Tag',id,...
            'HelpMapFile',RptgenML.getHelpMapfile,...
            'HelpMapKey',['category.StylesheetType.',lower(id)]);
            connect(returnedValue,ssLib,'up');
            set(h,['Category',id],returnedValue);
        end
    else
        returnedValue=storedValue;
    end
