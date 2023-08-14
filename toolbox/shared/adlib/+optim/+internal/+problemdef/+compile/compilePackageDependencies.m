function[subFunString,pkgDependencies]=compilePackageDependencies(pkgDependencies)






    if isempty(pkgDependencies)
        subFunString="";
        return;
    end


    uniquePackages=unique(pkgDependencies);




    delimiter=".*;"+newline+"import ";
    subFunString="import "+join(uniquePackages,delimiter)+...
    replace(delimiter,"import ","")+newline+newline;

end
