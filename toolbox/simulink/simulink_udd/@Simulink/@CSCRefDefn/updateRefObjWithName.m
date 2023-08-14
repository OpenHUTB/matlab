function updateRefObjWithName(hThis,cscName)




    pkgName=hThis.StoredRefPackageName;


    refObj=processcsc('GetCSCDefn',pkgName,cscName);


    if(isempty(refObj))
        DAStudio.error('Simulink:dialog:CSCRefDefnCannotUpdateRefObj',cscName,pkgName);
    end

    hThis.RefDefnObj=refObj;

end


