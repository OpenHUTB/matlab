function updateRefObjWithName(hThis,msName)




    pkgName=hThis.StoredRefPackageName;


    refObj=processcsc('GetMemorySectionDefn',pkgName,msName);


    if(isempty(refObj))
        DAStudio.error('Simulink:dialog:CSCRefDefnCannotUpdateRefObj',msName,pkgName);
    end

    hThis.RefDefnObj=refObj;

end


