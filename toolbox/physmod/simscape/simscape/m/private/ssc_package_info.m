function[pkg,parent]=ssc_package_info(command,providedPackage)














    if(nargin==1)
        [pkg,parent]=lDerivedInfo(command);
    else
        pkg=pm_charvector(providedPackage);
        parent=pwd;
        [maybePkg,maybeParent]=lPackageInfo();
        if~ismissing(maybePkg)
            lValidateProvidedName(pkg,maybePkg,command)
            parent=char(maybeParent);
        end
    end
end

function[pkg,parent]=lDerivedInfo(command)
    [maybePkg,maybeParent]=lPackageInfo();
    if ismissing(maybePkg)
        pm_error('physmod:simscape:simscape:ssc_build:NoArgument',command);
    else

        pm_assert(~ismissing(maybeParent),...
        'screen inputs returned invalid results');
        parent=char(maybeParent);
        pkg=char(maybePkg);
    end
end

function[pkg,parent]=lPackageInfo()




    cwd=string(pwd);
    pkg=string(missing);
    parent=string(missing);
    if contains(cwd,'+')
        getPackageName=ne_private('ne_packagenamefromdirectorypath');

        [parent,pkg]=getPackageName(char(cwd));
        pkg=string(pkg);
        parent=string(parent);
    end

end

function lValidateProvidedName(libName,derivedName,command)
    if~ismissing(derivedName)
        if~strcmp(derivedName,libName)


            pm_error('physmod:simscape:simscape:ssc_build:InconsistentNames',...
            libName,derivedName,command);
        else

            pm_warning('physmod:simscape:simscape:ssc_build:NameProvided',...
            command,libName);
        end
    end
end
