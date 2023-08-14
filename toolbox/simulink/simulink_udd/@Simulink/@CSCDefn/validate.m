function invalidCSCs=validate(hCSCDefn,invalidMSs,msDefns,pkgDir)











    if isstring(invalidMSs)
        invalidMSs=cellstr(invalidMSs);
    end

    pkgDir=convertStringsToChars(pkgDir);

    invalidCSCs={};
    myName=hCSCDefn.Name;

    try

        if RTW.isKeywordInTLC(myName)
            DAStudio.error('Simulink:dialog:CSCNameIsTLCKeyword',myName);
        end

        thisMemsecName=hCSCDefn.MemorySection;


        thisMemsecDefn=[];
        for j=1:length(msDefns)
            if strcmp(thisMemsecName,msDefns(j).Name)
                thisMemsecDefn=msDefns(j);
                break;
            end
        end

        if isempty(thisMemsecDefn)
            DAStudio.error('Simulink:dialog:CSCDefnReferNonExistMSDefn',...
            thisMemsecName,hCSCDefn.OwnerPackage);
        end


        if~isempty(invalidMSs)
            [r,loc]=ismember(thisMemsecName,invalidMSs(1,:));
            if r
                reason=invalidMSs{2,loc};
                DAStudio.error('Simulink:dialog:CSCRefDefnInvalidMS',...
                thisMemsecName,hCSCDefn.OwnerPackage,reason);
            end
        end

        LocalValidateCSCDefn(hCSCDefn,thisMemsecDefn,pkgDir);
    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        invalidCSCs={myName;tmpReason};
    end

end


function LocalValidateCSCDefn(cscDefn,msDefn,pkgDir)





    persistent slPkgPath

    if isempty(slPkgPath)
        slPkgPath=fileparts(processcsc('GetCSCRegFile','Simulink'));
    end


    if~isvarname(cscDefn.OwnerPackage)
        DAStudio.error('Simulink:dialog:CSCDefnInvalidOwnerPackage');
    end


    [~,pkgName]=fileparts(pkgDir);
    if strcmp(pkgName(2:end),cscDefn.OwnerPackage)

        ownerPkgPath=pkgDir;
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














    switch cscDefn.CSCType
    case 'Unstructured'
        if cscDefn.IsGrouped
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeUnstructuredIsGroupedFalse');
        end

        if~strcmp(cscDefn.TLCFileName,'Unstructured.tlc')
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeUnstructuredTLCFileName');
        end

        if~isempty(cscDefn.CSCTypeAttributesClassName)
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeUnstructuredClassNameEmpty');
        end

    case 'FlatStructure'
        if~cscDefn.IsGrouped
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeFlatStructureIsGroupedTrue');
        end

        tlcFile='FlatStructure.tlc';
        if~strcmp(cscDefn.TLCFileName,tlcFile)
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeFlatStructureTLCFileName',tlcFile);
        end

        className='Simulink.CSCTypeAttributes_FlatStructure';
        if~strcmp(cscDefn.CSCTypeAttributesClassName,className)
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeFlatStructureCSCTypeAttributesClassName',className);
        end

    case 'AccessFunction'
        if cscDefn.IsGrouped
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionIsGroupedFalse');
        end

        if~strcmp(cscDefn.TLCFileName,'GetSet.tlc')
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionTLCFileName');
        end

        if~strcmp(cscDefn.MemorySection,'Default')
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionWithMemorySection');
        end

        if~strcmp(cscDefn.DataScope,'Imported')
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionMustBeImported');
        end

        if(strcmp(cscDefn.DataInit,'Static')||...
            strcmp(cscDefn.DataInit,'Macro'))
            DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionWithInvalidDataInit');
        end

        if(~cscDefn.CSCTypeAttributes.IsGetFunctionInstanceSpecific)

            getFunction=strtrim(cscDefn.CSCTypeAttributes.GetFunction);

            if isempty(getFunction)
                if(cscDefn.DataUsage.IsParameter)

                    DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionEmptyGetFunctionForParameter');
                end

                if(~cscDefn.CSCTypeAttributes.IsSetFunctionInstanceSpecific&&...
                    isempty(strtrim(cscDefn.CSCTypeAttributes.SetFunction)))

                    DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionEmptyGetAndSetFunctions');
                end
            elseif isempty(strfind(getFunction,'$N'))

                DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionGetFunctionWithoutToken');
            end
        end

        if(~cscDefn.CSCTypeAttributes.IsSetFunctionInstanceSpecific)

            setFunction=strtrim(cscDefn.CSCTypeAttributes.SetFunction);

            if~isempty(setFunction)&&isempty(strfind(setFunction,'$N'))

                DAStudio.error('Simulink:dialog:CSCDefnCSCTypeAccessFunctionSetFunctionWithoutToken');
            end
        end

    end




    if cscDefn.IsGrouped
        grpTerm='Grouped';
        if strcmp(cscDefn.CSCType,'FlatStructure')
            grpTerm='FlatStructure';
        end

        if cscDefn.IsMemorySectionInstanceSpecific
            DAStudio.error('Simulink:dialog:CSCDefnInstantSpecificMS',grpTerm);
        end

        if cscDefn.IsDataScopeInstanceSpecific
            DAStudio.error('Simulink:dialog:CSCDefnInstantSpecificDataScope',grpTerm);
        end

        if cscDefn.IsDataInitInstanceSpecific
            DAStudio.error('Simulink:dialog:CSCDefnInstantSpecificDataInit',grpTerm);
        end

        if cscDefn.IsDataAccessInstanceSpecific
            DAStudio.error('Simulink:dialog:CSCDefnInstantSpecificDataAccess',grpTerm);
        end

        if cscDefn.IsHeaderFileInstanceSpecific
            DAStudio.error('Simulink:dialog:CSCDefnInstantSpecificHeaderFile',grpTerm);
        end

        if pragmasUseIdentifierSubstitution(msDefn)
            DAStudio.error('Simulink:dialog:CSCDefnMustBeUnstructuredForIdentifierSubstitution');
        end
    end


    if(slfeature('SeparateMemorySectionsForParamsAndSignals')==0)
        if cscDefn.DataUsage.IsSignal&&msDefn.getProp('IsConst')
            DAStudio.error('Simulink:dialog:CSCDefnSignalConstMemory');
        end
    else
        if cscDefn.DataUsage.IsParameter&&~msDefn.getProp('DataUsage').IsParameter
            DAStudio.error('Simulink:dialog:CSCDefnForParametersButNotMemorySection');
        end

        if cscDefn.DataUsage.IsSignal&&~msDefn.getProp('DataUsage').IsSignal
            DAStudio.error('Simulink:dialog:CSCDefnForSignalsButNotMemorySection');
        end
    end


    if cscDefn.DataUsage.IsParameter&&strcmp(cscDefn.DataInit,'Dynamic')
        DAStudio.error('Simulink:dialog:CSCDefnDataUsageParamDynamicInit');
    end


    if(cscDefn.DataUsage.IsParameter||~cscDefn.DataUsage.IsSignal)&&...
        (cscDefn.IsReusable||cscDefn.IsReusableInstanceSpecific)
        DAStudio.error('Simulink:dialog:CSCDefnIsSignalReusableInvalidSettingForParam');
    end


    if(cscDefn.DataUsage.IsParameter&&cscDefn.ConcurrentAccess)&&...
        (slfeature('LatchingForDataObjects')<2)
        DAStudio.error('Simulink:dialog:CSCDefnConcurrentAccessSettingForParam');
    end







    if strcmp(cscDefn.DataScope,'Imported')
        if strcmp(cscDefn.DataInit,'Static')

            DAStudio.error('Simulink:dialog:CSCDefnImportedDataInit');
        end

    elseif~strcmp(cscDefn.DataAccess,'Direct')

        DAStudio.error('Simulink:dialog:CSCDefnNonImportedDataPointer');
    end







    if strcmp(cscDefn.DataInit,'Macro')
        if cscDefn.DataUsage.IsSignal
            DAStudio.error('Simulink:dialog:CSCDefnSignalMacroInit');
        end

        if cscDefn.IsGrouped
            DAStudio.error('Simulink:dialog:CSCDefnIsGroupedMacroInit',grpTerm);
        end

        if~strcmp(cscDefn.DataAccess,'Direct')
            DAStudio.error('Simulink:dialog:CSCDefnDataAccessMacroInit');
        end

        if msDefn.getProp('IsConst')||msDefn.getProp('IsVolatile')||~isempty(msDefn.getProp('Qualifier'))
            DAStudio.error('Simulink:dialog:CSCDefnIsConstMacroInit');
        end
    end





    if((~isempty(cscDefn.HeaderFile))&&...
        (~strcmp(cscDefn.DataScope,'Imported')))
        errTxt=slprivate('check_generated_filename',cscDefn.HeaderFile,'.h');
        if~isempty(errTxt)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidHeaderFileExportedData',errTxt);
        end
    end

    if~isempty(cscDefn.DefinitionFile)&&strcmp(cscDefn.DataScope,'Exported')
        errTxt=slprivate('check_generated_filename',cscDefn.DefinitionFile,'.c');
        if~isempty(errTxt)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidDefinitionFileExportedData',errTxt);
        end
    end

    if~isempty(cscDefn.Owner)&&strcmp(cscDefn.DataScope,'Exported')
        if~isvarname(cscDefn.Owner)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidOwnerExportedData',cscDefn.Owner);
        end
    end



    if~strcmp(cscDefn.CommentSource,'Default')
        if~isempty(cscDefn.TypeComment)&&~iscComment(cscDefn.TypeComment)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidTypeComment');
        end

        if~isempty(cscDefn.DeclareComment)&&~iscComment(cscDefn.DeclareComment)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidDeclareComment');
        end

        if~isempty(cscDefn.DefineComment)&&~iscComment(cscDefn.DefineComment)
            DAStudio.error('Simulink:dialog:CSCDefnInvalidDefineComment');
        end
    end



    if~isempty(cscDefn.TLCFileName)
        if(strcmp(cscDefn.CSCType,'Unstructured')||...
            strcmp(cscDefn.CSCType,'FlatStructure')||...
            strcmp(cscDefn.CSCType,'AccessFunction'))

            filelong=[slPkgPath,filesep,'tlc',filesep,cscDefn.TLCFileName];
        else
            filelong=[ownerPkgPath,filesep,'tlc',filesep,cscDefn.TLCFileName];
        end

        if~exist(filelong,'file')
            DAStudio.error('Simulink:dialog:CSCDefnTLCFileNameExist',filelong);
        end
    end



    if~isempty(cscDefn.CSCTypeAttributesClassName)
        if isempty(cscDefn.CSCTypeAttributes)
            DAStudio.error('Simulink:dialog:CSCDefnCSCAttribClassInit',cscDefn.CSCTypeAttributesClassName);
        end
    end






    if strcmp(cscDefn.CSCType,'FlatStructure')
        hs=cscDefn.CSCTypeAttributes;
















        if~hs.IsStructNameInstanceSpecific
            tmpUniqIds={};



            if~iscvar(hs.StructName)
                DAStudio.error('Simulink:dialog:CSCDefnInvalidStructName');
            else
                tmpUniqIds=[tmpUniqIds,{hs.StructName}];
            end

            if hs.IsTypeDef
                if~iscvar(hs.TypeName)
                    DAStudio.error('Simulink:dialog:CSCDefnInvalidTypeName');
                else
                    tmpUniqIds=[tmpUniqIds,{hs.TypeName}];
                end

            else
                if~isempty(hs.TypeName)
                    DAStudio.error('Simulink:dialog:CSCDefnTypeNameEmpty');
                end

                if isempty(hs.TypeTag)
                    DAStudio.error('Simulink:dialog:CSCDefnTypeTagEmpty');
                end
            end





            if~isempty(hs.TypeTag)
                if~iscvar(hs.TypeTag)
                    DAStudio.error('Simulink:dialog:CSCDefnInvalidTypeTag');
                else
                    tmpUniqIds=[tmpUniqIds,{hs.TypeTag}];%#ok
                end
            end

        end
    end

end


function rtn=pragmasUseIdentifierSubstitution(msDefn)
    rtn=(contains(msDefn.PrePragma,'$N')||...
    contains(msDefn.PostPragma,'$N'));
end


function rtn=iscComment(comment)







    rtn=false;

    if ischar(comment)
        correctStartAndEnd=false;

        comment=strtrim(comment);
        len=length(comment);
        if len>=4
            correctStartAndEnd=strcmp(comment(1:2),'/*')&...
            (strfind(comment,'*/')==len-1);
        end

        if correctStartAndEnd
            rtn=true;
        end
    end

end


