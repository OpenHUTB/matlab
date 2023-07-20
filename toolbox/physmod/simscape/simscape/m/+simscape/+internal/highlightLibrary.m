function highlightLibrary(libraryname)






    filter='Simscape';
    if~strncmp(filter,libraryname,length(filter))
        pm_error('physmod:simscape:simscape:internal:highlightLibrary:LibraryWithin',libraryname);
    end


    lb=LibraryBrowser.LibraryBrowser2;


    lbc=lb.getLBComponents;


    lbc2=lbc{1};


    isSelected=lbc2.selectTreeNodeByName(libraryname);
    isExpanded=lbc2.expandTreeNodeByName(libraryname);
    if~isSelected||~isExpanded


        librarySeparator='/';
        libraryNames=strsplit(libraryname,librarySeparator);
        for libraryNamesIdx=1:length(libraryNames)
            thisLibraryName=strjoin(libraryNames(1:libraryNamesIdx),librarySeparator);
            isSelected=lbc2.selectTreeNodeByName(thisLibraryName);
            isExpanded=lbc2.expandTreeNodeByName(thisLibraryName);
            if~isSelected||~isExpanded
                pm_error('physmod:simscape:simscape:internal:highlightLibrary:LibraryExist',thisLibraryName);
            end
        end
    end


    lb.show;
end
