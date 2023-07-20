function invalidCSCs=validate(hCSCRefDefn,invalidMSs,msDefns,pkgDir)%#ok




    if isstring(invalidMSs)
        invalidMSs=cellstr(invalidMSs);
    end

    pkgDir=convertStringsToChars(pkgDir);

    invalidCSCs={};

    myName=hCSCRefDefn.Name;
    childPkg=hCSCRefDefn.RefPackageName;
    childName=hCSCRefDefn.RefDefnName;

    try


        if RTW.isKeywordInTLC(myName)
            DAStudio.error('Simulink:dialog:CSCNameIsTLCKeyword',myName);
        end


        localValidateNameOwnerPackage(hCSCRefDefn,pkgDir);


        hCSCRefDefn.updateRefObj;
        hCSCDefn=hCSCRefDefn.getRefDefnObj;
    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        invalidCSCs={myName;tmpReason};
        return;
    end

    refObjName=hCSCDefn.Name;
    try

        cscNames=processcsc('GetCSCNames',childPkg);
        if sum(ismember(cscNames,refObjName))>1
            DAStudio.error('Simulink:dialog:CSCRefDefnUniqueName',childName,childPkg);
        end


        childCSCMemDefns=processcsc('GetMemorySectionDefns',childPkg);


        childPkgDir=fileparts(processcsc('GetCSCRegFile',childPkg));
        tmpInvalidCSCs=hCSCDefn.validate(invalidMSs,childCSCMemDefns,childPkgDir);

        if~isempty(tmpInvalidCSCs)
            childReason=tmpInvalidCSCs{2};
            DAStudio.error('Simulink:dialog:CSCRefDefnInvalidMS',childName,childPkg,childReason);
        end
    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        invalidCSCs={myName;tmpReason};
    end







    function localValidateNameOwnerPackage(cscDefn,pkgDir)



        if~isvarname(cscDefn.OwnerPackage)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidOwnerPackage');
        end


        [~,pkgName]=fileparts(pkgDir);
        if strcmp(pkgName(2:end),cscDefn.OwnerPackage)

        else
            ownerPkgPath=fileparts(processcsc('GetCSCRegFile',cscDefn.OwnerPackage));
            if isempty(ownerPkgPath)
                DAStudio.error('Simulink:dialog:CSCDefnPackageNotFoundInPath',cscDefn.OwnerPackage);
            end
        end


        builtinSCs=coder.internal.getBuiltinStorageClasses;

        builtinSCs=[builtinSCs;'SimulinkGlobal'];

        if(ismember(cscDefn.Name,builtinSCs))
            DAStudio.error('Simulink:dialog:CSCDefnInvalidName2');
        elseif~isvarname(cscDefn.Name)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidName');
        end





