function checkCircularReference(hThis)




    myPackage=hThis.OwnerPackage;
    targetPackage=hThis.RefPackageName;
    try
        processcsc('CheckCircularReference',myPackage,targetPackage);
    catch err
        DAStudio.error('Simulink:dialog:CSCRefDefnCannotSetRefPkg',...
        targetPackage,myPackage,hThis.Name,err.message);
    end





