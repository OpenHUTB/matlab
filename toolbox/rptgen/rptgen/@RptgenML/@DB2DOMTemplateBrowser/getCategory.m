function returnedValue=getCategory(h,storedValue,id,displayName,isVisible)




    if isempty(storedValue)
        tLib=h.TemplateLibrary;
        if isempty(tLib)
            getTemplateLibrary(h);
            returnedValue=get(h,['Category',id]);
        else
            returnedValue=RptgenML.LibraryCategory(displayName,...
            'Visible',isVisible,...
            'Tag',id,...
            'HelpMapFile',RptgenML.getHelpMapfile,...
            'HelpMapKey',['category.DB2DOMTemplateType.',lower(id)]);
            connect(returnedValue,tLib,'up');
            set(h,['Category',id],returnedValue);
        end
    else
        returnedValue=storedValue;
    end
