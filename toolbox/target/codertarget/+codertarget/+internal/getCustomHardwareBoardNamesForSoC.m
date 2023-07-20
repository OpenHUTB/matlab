function out=getCustomHardwareBoardNamesForSoC





    out={};
    regPlugins=getAllPluginsOnPath('soc.internal.customboard.register');
    for i=1:numel(regPlugins)
        regPluginObj=eval(regPlugins{i});
        out=[out,regPluginObj.getSupportedHwBoards];
    end
end


function allPlugins=getAllPluginsOnPath(pkgName)

    metaObj=meta.package.fromName(pkgName);
    allPlugins={};
    if isempty(metaObj)
        return
    end

    allClassesInPackage=metaObj.ClassList;
    allPlugins={};
    for i=1:numel(allClassesInPackage)
        superClass=allClassesInPackage(i).SuperclassList;
        if~isempty(superClass)
            superClassNames={allClassesInPackage(i).SuperclassList.Name};
            if ismember('soc.internal.customboard.TargetHardwarePlugin',superClassNames)||...
                ismember('codertarget.internal.TargetHardwarePlugin',superClassNames)
                allPlugins{end+1}=allClassesInPackage(i).Name;%#ok<AGROW>
            end
        end

    end
end
