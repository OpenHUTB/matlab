function[invalidMSs]=validate(hMSRefDefn)




    invalidMSs={};

    myName=hMSRefDefn.Name;
    childPkg=hMSRefDefn.RefPackageName;
    childName=hMSRefDefn.RefDefnName;

    try


        if RTW.isKeywordInTLC(myName)
            DAStudio.error('Simulink:dialog:MSNameIsTLCKeyword',myName);
        end


        if~isvarname(hMSRefDefn.Name)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidName');
        end


        hMSRefDefn.updateRefObj;
        hMSDefn=hMSRefDefn.getRefDefnObj;
    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        invalidMSs={myName;tmpReason};
        return;
    end

    refObjName=hMSDefn.Name;
    try

        msNames=processcsc('GetMemorySectionNames',childPkg);
        if sum(ismember(msNames,refObjName))>1
            DAStudio.error('Simulink:dialog:MSRefDefnUniqueName',childName,childPkg);
        end


        [tmpInvalidMSs]=hMSDefn.validate;

        if~isempty(tmpInvalidMSs)
            childReason=tmpInvalidMSs{2};
            DAStudio.error('Simulink:dialog:CSCRefDefnInvalidMS',childName,childPkg,childReason);
        end
    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        invalidMSs=[invalidMSs,{myName;tmpReason}];
    end




