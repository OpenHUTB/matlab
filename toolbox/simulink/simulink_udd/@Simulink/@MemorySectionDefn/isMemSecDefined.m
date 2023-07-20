function isDefined=isMemSecDefined(pkgName,memSecName)




    if nargin>0
        pkgName=convertStringsToChars(pkgName);
    end

    if nargin>1
        memSecName=convertStringsToChars(memSecName);
    end

    memSec=processcsc('GetMemorySectionDefn',pkgName,memSecName);
    isDefined=~isempty(memSec);



