function out=dependentversions(file)












    deps=simscape.dependency.internal.file_recursion(file,...
    simscape.DependencyType.Core,...
    true);


    fdirpath=ne_private('ne_packagenamefromdirectorypath');
    [pkgDir,pkg]=fdirpath(file);
    pkgpth=fullfile(pkgDir,['+',pkg]);

    out=containers.Map;
    for i=1:numel(deps)
        if startsWith(deps{i},pkgpth)
            continue;
        end

        depPkg=ltopLevelPkg(deps{i});
        if isempty(depPkg)
            continue;
        end

        if~out.isKey(depPkg)
            out(depPkg)=simscape.versioning.internal.libversion(depPkg);
        end
    end

end

function pkg=ltopLevelPkg(pth)
    pkg='';
    toks=regexp(pth,['\',filesep,'\+([^\',filesep,'])+\',filesep],'tokens');
    if~isempty(toks)
        pkg=toks{1}{1};
    end
end