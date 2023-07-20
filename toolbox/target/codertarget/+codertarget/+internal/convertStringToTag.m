function pkgTag=convertStringToTag(sppkgStr)




    validateattributes(sppkgStr,{'char'},{'nonempty'},'convertStringToTag','sppkgStr');


    pkgTag=regexprep(sppkgStr,'\(R\)','');
    pkgTag=regexprep(pkgTag,'\W','');
    pkgTag=lower(pkgTag);

