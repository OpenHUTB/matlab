function bEdit=isEditableProperty(h,propName)




    switch propName
    case{'Name','SourcePath'}
        bEdit=false;
    otherwise
        bEdit=true;
    end

end

