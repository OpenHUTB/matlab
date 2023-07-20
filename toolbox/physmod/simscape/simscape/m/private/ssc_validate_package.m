function ssc_validate_package(command,pkg,parent)




    if isempty(pkg)
        pm_error('physmod:simscape:simscape:ssc_build:InvalidArgument');
    elseif strcmp(pkg(1),'+')
        pm_error('physmod:simscape:simscape:ssc_build:InvalidArgument');
    end

    if~isvarname(pkg)
        pm_error('physmod:simscape:simscape:ssc_build:InvalidPackage',...
        pkg);
    end

    if~isfolder(fullfile(parent,strcat('+',pkg)))
        pm_error('physmod:simscape:simscape:ssc_build:CannotFindPackage',...
        pkg,command,pkg);
    end
end