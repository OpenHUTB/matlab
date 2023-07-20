function usesEditW=isUsingEditWidget(h,propName)
    if(any(strmatch(propName,h.editWidgetList,'exact')))
        usesEditW=true;
    else
        usesEditW=false;
    end
end
