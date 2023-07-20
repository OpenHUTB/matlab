function[dependencyList,parentList]=getSpPkgDownstreamList(spPkgName,pkgList,options)

































    if~exist('options','var')
        options=struct();
    end

    validateattributes(spPkgName,{'char'},{'nonempty'},'getSpPkgDownstreamList','spPkgName');
    validateattributes(pkgList,{'hwconnectinstaller.SupportPackage'},{},'getSpPkgDownstreamList','pkgList');

    if~isfield(options,'missingPackageAction')
        options.missingPackageAction='error';
    end

    [dependencyList,parentList]=processSupportPackage(spPkgName,pkgList,hwconnectinstaller.SupportPackage.empty,options);
    assert(numel(dependencyList)==numel(parentList));
end


function[dependencyList,parentList]=processSupportPackage(spPkgName,pkgList,parent,options)

    dependencyList=hwconnectinstaller.SupportPackage.empty;
    parentList={};

    ind=find(strcmp(spPkgName,{pkgList.Name}),1,'first');
    if isempty(ind)
        switch options.missingPackageAction
        case 'error'
            error(message('hwconnectinstaller:installapi:MissingRequiredSupportPackage',spPkgName));
        case 'warning'
            warning(message('hwconnectinstaller:installapi:MissingRequiredSupportPackage',spPkgName));
            return;
        case 'none'

            return;
        otherwise
            assert(false,'Invalid missingPackageAction');
        end
    end

    spPkg=pkgList(ind);


    for i=1:length(spPkg.Children)
        [tmpDepList,tmpParentList]=processSupportPackage(spPkg.Children(i).Name,pkgList,spPkg,options);
        dependencyList=[dependencyList,tmpDepList];%#ok<AGROW>
        parentList=[parentList,tmpParentList];%#ok<AGROW>
    end

    dependencyList=[dependencyList,spPkg];
    parentList=[parentList,{parent}];
end
