classdef ConflictChecks



















































    methods(Static)













        function hardConflictPkgs=checkUninstall(pkgToUninstall,installedPkgs)
            if isempty(installedPkgs)
                installedPkgs=hwconnectinstaller.SupportPackage.empty;
            end

            validateattributes(pkgToUninstall,{'char'},{'nonempty'},'checkUninstallConflict','pkgToUninstall');
            validateattributes(installedPkgs,{'hwconnectinstaller.SupportPackage'},{},'checkUninstall','installedPkgs');

            index=find(strcmp(pkgToUninstall,{installedPkgs.Name}));
            if isempty(index)

                hardConflictPkgs=hwconnectinstaller.SupportPackage.empty;
                return;
            end
            pkgToUninstall=installedPkgs(index(1));
            installedParentsMap=getParentMap(installedPkgs);
            hardConflictPkgs=getAllAncestors(pkgToUninstall,installedParentsMap);


            hardConflictPkgs(~[hardConflictPkgs.Visible])=[];
            hardConflictPkgs=removeDuplicates(hardConflictPkgs);
        end






























        function[hardConflictPkgs,softConflictPkgs,requiredVisiblePkgs]=...
            checkInstallOrUpdate(pkgToInstallOrUpdate,availablePkgs,installedPkgs)

            if isempty(availablePkgs)
                availablePkgs=hwconnectinstaller.SupportPackage.empty;
            end

            if isempty(installedPkgs)
                installedPkgs=hwconnectinstaller.SupportPackage.empty;
            end

            validateattributes(pkgToInstallOrUpdate,{'char'},{'nonempty'},'checkInstallOrUpdate','pkgToInstallOrUpdate');
            validateattributes(availablePkgs,{'hwconnectinstaller.SupportPackage'},{},'checkInstallOrUpdate','availablePkgs');
            validateattributes(installedPkgs,{'hwconnectinstaller.SupportPackage'},{},'checkInstallOrUpdate','installedPkgs');

            installedParentsMap=getParentMap(installedPkgs);







            allRequiredPkgs=hwconnectinstaller.util.getSpPkgDownstreamList(...
            pkgToInstallOrUpdate,availablePkgs,struct('missingPackageAction','none'));
            allRequiredPkgs=removeDuplicates(allRequiredPkgs);

            potentialConflicts=hwconnectinstaller.SupportPackage.empty;
            for i=1:numel(allRequiredPkgs)
                pkg=allRequiredPkgs(i);
                if needToUpdate(pkg,installedPkgs)


                    potentialConflicts=[potentialConflicts,pkg...
                    ,getAllAncestors(pkg,installedParentsMap)];%#ok<AGROW>
                else


                end
            end
            potentialConflicts=removeDuplicates(potentialConflicts);




            potentialConflicts(~[potentialConflicts.Visible])=[];


            isPkgToInstall=strcmp({allRequiredPkgs.Name},pkgToInstallOrUpdate);
            allRequiredDescendants=allRequiredPkgs(~isPkgToInstall);
            [~,softConflictIndices]=intersect({potentialConflicts.Name},{allRequiredDescendants.Name});
            softConflictPkgs=potentialConflicts(softConflictIndices);


            [~,hardConflictIndices]=setdiff({potentialConflicts.Name},{allRequiredPkgs.Name});
            hardConflictPkgs=potentialConflicts(hardConflictIndices);

            requiredVisiblePkgs=allRequiredDescendants([allRequiredDescendants.Visible]);



            requiredVisiblePkgs=removeDuplicates(requiredVisiblePkgs);
        end

    end


end






function allParents=getAllAncestors(pkg,parentMap)
    allParents=hwconnectinstaller.SupportPackage.empty;
    if~isKey(parentMap,pkg.Name)
        return;
    end
    directParents=parentMap(pkg.Name);
    allParents=directParents;
    for i=1:numel(directParents)
        allParents=[allParents...
        ,getAllAncestors(directParents(i),parentMap)];%#ok<AGROW>
    end
end





function doUpdate=needToUpdate(webPkg,installedPkgList)
    doUpdate=false;
    for k=1:numel(installedPkgList)
        if strcmp(installedPkgList(k).Name,webPkg.Name)
            doUpdate=webPkg.compareVersionTo(installedPkgList(k))>0;
            break;
        end
    end
end






function parentMap=getParentMap(pkglist)
    parentMap=containers.Map;


    for i=1:numel(pkglist)
        parentMap(pkglist(i).Name)=hwconnectinstaller.SupportPackage.empty;
    end

    for i=1:numel(pkglist)
        for j=1:numel(pkglist(i).Children)
            childName=pkglist(i).Children(j).Name;
            parentMap(childName)=[parentMap(childName),pkglist(i)];
        end
    end
end


function pkglist=removeDuplicates(pkglist)
    [~,indices]=unique({pkglist.Name});
    pkglist=pkglist(indices);
end
