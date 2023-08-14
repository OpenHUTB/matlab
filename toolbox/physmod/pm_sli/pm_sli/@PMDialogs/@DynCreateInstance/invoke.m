function hObj=invoke(hThis,fullClassNameStr,hBlk)



    hObj=0;


    fullClsName=fullClassNameStr;
    [pkgName,restOfStr]=strtok(fullClsName,'.');
    [clsName]=strtok(restOfStr,'.');


    if(strncmp('Pm',clsName,2)==true)
        clsName=clsName(3:length(clsName));
    end

    clsPrefix='Dyn';
    derivedClsName=[clsPrefix,clsName];


    hPkg=findpackage(pkgName);
    if(isempty(hPkg))
        error(['createInstance: unrecognized package name',' ''',pkgName,'''']);
    end
    hClassObj=hPkg.findclass(derivedClsName);
    if(isempty(hClassObj))
        error(['createInstance: unrecognized class name',' ''',derivedClsName,'''']);
    end

    fullClsNameStr=[pkgName,'.',clsPrefix,clsName];
    hObj=feval(fullClsNameStr,hBlk);
