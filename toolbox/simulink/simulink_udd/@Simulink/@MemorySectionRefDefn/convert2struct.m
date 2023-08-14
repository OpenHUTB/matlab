function theStruct=convert2struct(hThis)





    oldRefObj=hThis.getRefDefnObj;
    hThis.updateRefObj;


    actualDefnObj=hThis.getRefDefnObj;

    if~isequal(oldRefObj,actualDefnObj)
        DAStudio.error('Simulink:dialog:CSCRefDefnOutOfDateRefDefnObject');
    end

    theStruct=actualDefnObj.convert2struct;


    theStruct.Name=hThis.Name;
    theStruct.OwnerPackage=hThis.OwnerPackage;


    theStruct.RefPackageName=hThis.RefPackageName;
    theStruct.RefDefnName=hThis.RefDefnName;





