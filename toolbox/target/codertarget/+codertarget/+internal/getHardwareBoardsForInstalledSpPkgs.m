function out=getHardwareBoardsForInstalledSpPkgs(in,isOutUnique)





    validatestring(in,{'soc','ec','all'});
    if~exist('isOutUnique','var')
        isOutUnique=true;
    end

    switch(in)
    case 'soc'
        pkgName={'soc.internal.register','soc.internal.customboard.register'};
    case 'ec'
        pkgName={'codertarget.internal.register'};
    case 'all'
        pkgName={'soc.internal.register','codertarget.internal.register'};
        isOutUnique=true;
    end
    out={};
    regPlugins=getAllPluginsOnPath(pkgName);
    for i=1:numel(regPlugins)
        regPluginObj=eval(regPlugins{i});
        out=[out,regPluginObj.getSupportedHwBoards];
    end

    if isOutUnique
        out=unique(out);
    end
end

function allPlugins=getAllPluginsOnPath(pkgName)
    allClassesInPackage=[];
    for i=1:numel(pkgName)
        metaObj=meta.package.fromName(pkgName{i});
        if~isempty(metaObj)
            allClassesInPackage=[allClassesInPackage;metaObj.ClassList];
        end
    end
    allPlugins={};

    for i=1:numel(allClassesInPackage)
        superClass=allClassesInPackage(i).SuperclassList;
        if~isempty(superClass)
            superClassNames=superclasses(allClassesInPackage(i).Name);
            if ismember('codertarget.internal.TargetHardwarePlugin',superClassNames)
                allPlugins{end+1}=allClassesInPackage(i).Name;%#ok<AGROW>
            end
        end

    end
end