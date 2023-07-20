function hNewContainer=deep_copy(hOldContainer)





    hNewContainer=hOldContainer.copy;


    hOldPackages=hOldContainer.Packages;
    hNewPackages=[];
    for i=1:length(hOldPackages)
        hNewPackages=[hNewPackages;hOldPackages(i).deep_copy];
    end
    hNewContainer.Packages=hNewPackages;
