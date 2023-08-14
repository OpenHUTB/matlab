function items=package_items(pkgName)




    mpkg=meta.package.fromName(pkgName);
    if isempty(mpkg)
        items={};
        return;
    end


    items={mpkg.ClassList.Name};





    items=[items,strcat([mpkg.Name,'.'],{mpkg.FunctionList.Name})];


    items=[items,{mpkg.PackageList.Name}];


    items=unique(items);
