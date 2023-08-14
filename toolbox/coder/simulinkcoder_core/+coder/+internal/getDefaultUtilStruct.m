function utilStruct=getDefaultUtilStruct(modelName,buildHooks,targetType,lTopModelStandalone,cs)





    utilStruct=loc_create_default_util_struct();

    utilStruct.targetInfoStruct.ShiftRightIntArith=strtrim(get_param(cs,'TargetShiftRightIntArith'));
    utilStruct.targetInfoStruct.ProdShiftRightIntArith=strtrim(get_param(cs,'ProdShiftRightIntArith'));
    utilStruct.targetInfoStruct.Endianess=strtrim(get_param(cs,'TargetEndianess'));
    utilStruct.targetInfoStruct.ProdEndianess=strtrim(get_param(cs,'ProdEndianess'));
    utilStruct.targetInfoStruct.wordlengths=[num2str(get_param(cs,'TargetBitPerChar')),',',num2str(get_param(cs,'TargetBitPerShort')),...
    ',',num2str(get_param(cs,'TargetBitPerInt')),',',num2str(get_param(cs,'TargetBitPerLong')),...
    ',',num2str(get_param(cs,'TargetBitPerLongLong')),',',num2str(get_param(cs,'TargetBitPerFloat')),...
    ',',num2str(get_param(cs,'TargetBitPerDouble')),',',num2str(get_param(cs,'TargetBitPerPointer')),...
    ',',num2str(get_param(cs,'TargetBitPerSizeT')),',',num2str(get_param(cs,'TargetBitPerPtrDiffT'))];
    utilStruct.targetInfoStruct.Prodwordlengths=strtrim([get_param(modelName,'ProdHWWordLengths'),...
    ',',num2str(get_param(cs,'ProdBitPerFloat')),',',num2str(get_param(cs,'ProdBitPerDouble')),...
    ',',num2str(get_param(cs,'ProdBitPerPointer')),...
    ',',num2str(get_param(cs,'ProdBitPerSizeT')),',',num2str(get_param(cs,'ProdBitPerPtrDiffT'))]);
    utilStruct.targetInfoStruct.TargetIntDivRoundTo=strtrim(get_param(cs,'TargetIntDivRoundTo'));
    utilStruct.targetInfoStruct.ProdIntDivRoundTo=strtrim(get_param(cs,'ProdIntDivRoundTo'));
    utilStruct.targetInfoStruct.TargetWordSize=strtrim(num2str(get_param(cs,'TargetWordSize')));
    utilStruct.targetInfoStruct.ProdWordSize=strtrim(num2str(get_param(cs,'ProdWordSize')));
    utilStruct.targetInfoStruct.HardwareBoard=get_param(cs,'HardwareBoard');
    utilStruct.targetInfoStruct.TargetHWDeviceType=strtrim(target.internal.resolveHWDeviceType(get_param(cs,'TargetHWDeviceType')));
    utilStruct.targetInfoStruct.ProdHWDeviceType=strtrim(target.internal.resolveHWDeviceType(get_param(cs,'ProdHWDeviceType')));
    utilStruct.targetInfoStruct.UseDivisionForNetSlopeComputation=strtrim(get_param(cs,'UseDivisionForNetSlopeComputation'));
    utilStruct.targetInfoStruct.ProdLargestAtomicInteger=strtrim(get_param(cs,'ProdLargestAtomicInteger'));
    utilStruct.targetInfoStruct.ProdLargestAtomicFloat=strtrim(get_param(cs,'ProdLargestAtomicFloat'));
    utilStruct.targetInfoStruct.TargetLargestAtomicInteger=strtrim(get_param(cs,'TargetLargestAtomicInteger'));
    utilStruct.targetInfoStruct.TargetLargestAtomicFloat=strtrim(get_param(cs,'TargetLargestAtomicFloat'));
    utilStruct.targetInfoStruct.LongLongMode=strtrim(get_param(cs,'TargetLongLongMode'));
    utilStruct.targetInfoStruct.ProdLongLongMode=strtrim(get_param(cs,'ProdLongLongMode'));


    RTWReplacementTypesON=rtwprivate('rtwattic','AtticData','isReplacementOn');
    if RTWReplacementTypesON
        utilStruct.targetInfoStruct.RTWReplacementTypes='';

        infoString='';
        RTWReplacementTypesStruct=get_param(cs,'ReplacementTypes');
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.double,'real_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.single,'real32_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.int32,'int32_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.int16,'int16_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.int8,'int8_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.uint32,'uint32_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.uint16,'uint16_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.uint8,'uint8_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.boolean,'boolean_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.int,'int_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.uint,'uint_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.char,'char_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.uint64,'uint64_T')];
        infoString=[infoString,newline,loc_analyze_aliastype(RTWReplacementTypesStruct.int64,'int64_T')];
        utilStruct.targetInfoStruct.RTWReplacementTypes=[infoString,newline];
    end


    utilStruct.targetInfoStruct.TargetLang=get_param(cs,'TargetLang');


    utilStruct.targetInfoStruct.TargetLangStd=get_param(cs,'TargetLangStandard');


    instSetExts=get_param(cs,'InstructionSetExtensions');
    numEls=size(instSetExts);
    commaStr='';
    instSetStr='';
    for idx=1:numEls(2)
        instSetStr=[instSetStr,commaStr,instSetExts{idx}];%#ok<*AGROW>
        commaStr=', ';
    end
    utilStruct.targetInfoStruct.InstructionSetExtions=instSetStr;


    utilStruct.targetInfoStruct.TflName=get_param(cs,'CodeReplacementLibrary');



    if~contains(utilStruct.targetInfoStruct.TflName,coder.internal.getCrlLibraryDelimiter)
        localTR=RTW.TargetRegistry.get();
        tfl=coder.internal.getTfl(localTR,utilStruct.targetInfoStruct.TflName);
        if(~isempty(tfl))
            utilStruct.targetInfoStruct.TflName=tfl.Name;
        end
    end


    locTflControl=get_param(modelName,'TargetFcnLibHandle');
    locCheckSum=locTflControl.getIncrBuildNum();
    utilStruct.targetInfoStruct.TflCheckSum=[locCheckSum.NUM1,...
    locCheckSum.NUM2,...
    locCheckSum.NUM3,...
    locCheckSum.NUM4];


    if strcmp(get_param(cs,'IsERTTarget'),'on')
        [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
        isCMappingActive=~isempty(modelMapping)&&isequal(mappingType,'CoderDictionary');
        if isCMappingActive

            msName=codermapping.internal.c.defaultmapping.getFunctionDefaultsMemSecPropValue(get_param(modelName,'Handle'),'SharedUtility','Name');


            if~isempty(msName)
                msElement=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataType(get_param(modelName,'Handle'),...
                'MemorySections',msName);
                msClassName=msElement.getClass();
                if strcmp(msClassName,'LegacyMemorySection')
                    msDefn=processcsc('GetMemorySectionDefn',msElement.getProperty('Package'),msElement.getProperty('DisplayName'));
                    utilStruct.targetInfoStruct.UtilMemSecPreStatement=msDefn.PrePragma;
                    utilStruct.targetInfoStruct.UtilMemSecPostStatement=msDefn.PostPragma;
                    utilStruct.targetInfoStruct.UtilMemSecComment=msDefn.Comment;
                else
                    utilStruct.targetInfoStruct.UtilMemSecPreStatement=msElement.getProperty('PreStatement');
                    utilStruct.targetInfoStruct.UtilMemSecPostStatement=msElement.getProperty('PostStatement');
                    utilStruct.targetInfoStruct.UtilMemSecComment=msElement.getProperty('Comment');
                end
            end
        else
            msName=get_param(cs,'MemSecFuncSharedUtil');
            pkg=get_param(cs,'MemSecPackage');
            if~strcmp(pkg,'---None---')
                if strcmp(msName,'Default')
                    utilStruct.targetInfoStruct.UtilMemSecPreStatement='';
                    utilStruct.targetInfoStruct.UtilMemSecPostStatement='';
                    utilStruct.targetInfoStruct.UtilMemSecComment='';
                else
                    msDefn=processcsc('GetMemorySectionDefn',pkg,msName);
                    utilStruct.targetInfoStruct.UtilMemSecPreStatement=msDefn.PrePragma;
                    utilStruct.targetInfoStruct.UtilMemSecPostStatement=msDefn.PostPragma;
                    utilStruct.targetInfoStruct.UtilMemSecComment=msDefn.Comment;
                end
            end
        end
    end



    if slprivate('isSimulationBuild',modelName,targetType)
        utilStruct.targetInfoStruct.CodeCoverageChecksum=[0,0,0,0];
    else
        utilStruct.targetInfoStruct.CodeCoverageChecksum=...
        coder.coverage.getSharedUtilsChecksum(buildHooks,lTopModelStandalone);
    end



    if strcmp(get_param(cs,'IsERTTarget'),'on')
        utilStruct.targetInfoStruct.PurelyIntegerCode=get_param(cs,'PurelyIntegerCode');
        utilStruct.targetInfoStruct.SupportNonInlinedSFcns=get_param(cs,'SupportNonInlinedSFcns');
        utilStruct.targetInfoStruct.PortableWordSizes=get_param(cs,'PortableWordSizes');


        utilStruct.targetInfoStruct.PreserveExternInFcnDecls=get_param(cs,'PreserveExternInFcnDecls');


        utilStruct.targetInfoStruct.ImplementImageWithCVMat=get_param(cs,'ImplementImageWithCVMat');


        utilStruct.targetInfoStruct.EnableSignedRightShifts=get_param(modelName,'EnableSignedRightShifts');
        utilStruct.targetInfoStruct.EnableSignedLeftShifts=get_param(modelName,'EnableSignedLeftShifts');


        utilStruct.targetInfoStruct.MaxIdInt8=strtrim(get_param(cs,'MaxIdInt8'));
        utilStruct.targetInfoStruct.MinIdInt8=strtrim(get_param(cs,'MinIdInt8'));
        utilStruct.targetInfoStruct.MaxIdUint8=strtrim(get_param(cs,'MaxIdUint8'));
        utilStruct.targetInfoStruct.MaxIdInt16=strtrim(get_param(cs,'MaxIdInt16'));
        utilStruct.targetInfoStruct.MinIdInt16=strtrim(get_param(cs,'MinIdInt16'));
        utilStruct.targetInfoStruct.MaxIdUint16=strtrim(get_param(cs,'MaxIdUint16'));
        utilStruct.targetInfoStruct.MaxIdInt32=strtrim(get_param(cs,'MaxIdInt32'));
        utilStruct.targetInfoStruct.MinIdInt32=strtrim(get_param(cs,'MinIdInt32'));
        utilStruct.targetInfoStruct.MaxIdUint32=strtrim(get_param(cs,'MaxIdUint32'));
        utilStruct.targetInfoStruct.MaxIdInt64=strtrim(get_param(cs,'MaxIdInt64'));
        utilStruct.targetInfoStruct.MinIdInt64=strtrim(get_param(cs,'MinIdInt64'));
        utilStruct.targetInfoStruct.MaxIdUint64=strtrim(get_param(cs,'MaxIdUint64'));
        utilStruct.targetInfoStruct.BooleanTrueId=strtrim(get_param(cs,'BooleanTrueId'));
        utilStruct.targetInfoStruct.BooleanFalseId=strtrim(get_param(cs,'BooleanFalseId'));
        utilStruct.targetInfoStruct.TypeLimitIdReplacementHeaderFile=strtrim(get_param(cs,'TypeLimitIdReplacementHeaderFile'));


        lSharedCode=get_param(cs,'ExistingSharedCode');
        if isempty(lSharedCode)
            lSharedCode=get_param(cs,'SharedCodeRepository');
        end
        utilStruct.targetInfoStruct.SharedCodeRepository=lSharedCode;
    end
end


function utilStruct=loc_create_default_util_struct
    utilStruct.targetInfoStruct.ShiftRightIntArith='';
    utilStruct.description.ShiftRightIntArith='Hardware  Impl:: shift right on a signed integer as arithmetic shift ';
    utilStruct.targetInfoStruct.ProdShiftRightIntArith='';
    utilStruct.description.ProdShiftRightIntArith='Hardware  Impl:: production shift right on a signed integer as arithmetic shift ';
    utilStruct.targetInfoStruct.Endianess='';
    utilStruct.description.Endianess='Hardware  Impl:: byte ordering';
    utilStruct.targetInfoStruct.ProdEndianess='';
    utilStruct.description.ProdEndianess='Hardware  Impl:: production byte ordering';
    utilStruct.targetInfoStruct.wordlengths='';
    utilStruct.description.wordlengths='Hardware  Impl:: word length';
    utilStruct.targetInfoStruct.Prodwordlengths='';
    utilStruct.description.Prodwordlengths='Hardware  Impl:: production word length';
    utilStruct.targetInfoStruct.TargetWordSize='';
    utilStruct.description.TargetWordSize='Hardware  Impl:: native word size';
    utilStruct.targetInfoStruct.ProdWordSize='';
    utilStruct.description.ProdWordSize='Hardware  Impl:: production native word size';
    utilStruct.targetInfoStruct.TargetHWDeviceType='';
    utilStruct.description.TargetHWDeviceType='Hardware  Impl:: device type';
    utilStruct.targetInfoStruct.ProdHWDeviceType='';
    utilStruct.description.ProdHWDeviceType='Hardware  Impl:: production device type';
    utilStruct.targetInfoStruct.TargetIntDivRoundTo='';
    utilStruct.description.TargetIntDivRoundTo='Hardware  Impl:: signed integer division round to';
    utilStruct.targetInfoStruct.ProdIntDivRoundTo='';
    utilStruct.description.ProdIntDivRoundTo='Hardware  Impl:: production signed integer division round to';
    utilStruct.targetInfoStruct.UseDivisionForNetSlopeComputation='';
    utilStruct.description.UseDivisionForNetSlopeComputation='Optimization:: controls the use of division to compute the net slope';
    utilStruct.targetInfoStruct.PurelyIntegerCode='off';
    utilStruct.description.PurelyIntegerCode='RTW Interface:: support floating-point numbers';
    utilStruct.targetInfoStruct.PortableWordSizes='off';
    utilStruct.description.PortableWordSizes='RTW Interface:: enable portable word sizes';
    utilStruct.targetInfoStruct.SupportNonInlinedSFcns='';
    utilStruct.description.SupportNonInlinedSFcns='RTW Interface:: support non-inlined s-functions';
    utilStruct.targetInfoStruct.RTWReplacementTypes='';
    utilStruct.description.RTWReplacementTypes='RTW: Replacement Data Types';
    utilStruct.targetInfoStruct.MaxIdInt8='MAX_int8_T';
    utilStruct.description.MaxIdInt8='RTW: Type MAX limit replacement for int8';
    utilStruct.targetInfoStruct.MinIdInt8='MIN_int8_T';
    utilStruct.description.MinIdInt8='RTW: Type MIN limit replacement for int8';
    utilStruct.targetInfoStruct.MaxIdUint8='MAX_uint8_T';
    utilStruct.description.MaxIdUint8='RTW: Type MAX limit replacement for uint8';
    utilStruct.targetInfoStruct.MaxIdInt16='MAX_int16_T';
    utilStruct.description.MaxIdInt16='RTW: Type MAX limit replacement for int16';
    utilStruct.targetInfoStruct.MinIdInt16='MIN_int16_T';
    utilStruct.description.MinIdInt16='RTW: Type MIN limit replacement for int16';
    utilStruct.targetInfoStruct.MaxIdUint16='MAX_uint16_T';
    utilStruct.description.MaxIdUint16='RTW: Type MAX limit replacement for uint16';
    utilStruct.targetInfoStruct.MaxIdInt32='MAX_int32_T';
    utilStruct.description.MaxIdInt32='RTW: Type MAX limit replacement for int32';
    utilStruct.targetInfoStruct.MinIdInt32='MIN_int32_T';
    utilStruct.description.MinIdInt32='RTW: Type MIN limit replacement for int32';
    utilStruct.targetInfoStruct.MaxIdUint32='MAX_uint32_T';
    utilStruct.description.MaxIdUint32='RTW: Type MAX limit replacement for uint32';
    utilStruct.targetInfoStruct.MaxIdInt64='MAX_int64_T';
    utilStruct.description.MaxIdInt64='RTW: Type MAX limit replacement for int64';
    utilStruct.targetInfoStruct.MinIdInt64='MIN_int64_T';
    utilStruct.description.MinIdInt64='RTW: Type MIN limit replacement for int64';
    utilStruct.targetInfoStruct.MaxIdUint64='MAX_uint64_T';
    utilStruct.description.MaxIdUint64='RTW: Type MAX limit replacement for uint64';
    utilStruct.targetInfoStruct.BooleanTrueId='true';
    utilStruct.description.BooleanTrueId='RTW: Boolean true identifier replacement';
    utilStruct.targetInfoStruct.BooleanFalseId='false';
    utilStruct.description.BooleanFalseId='RTW: Boolean false identifier replacement';
    utilStruct.targetInfoStruct.TypeLimitIdReplacementHeaderFile='';
    utilStruct.description.TypeLimitIdReplacementHeaderFile='RTW: Type limit identifiers replacement imported header file.';
    utilStruct.targetInfoStruct.SharedCodeRepository='';
    utilStruct.description.SharedCodeRepository='Repository for shared utility source files';
    utilStruct.description.TargetLang='Target language selection';
    utilStruct.targetInfoStruct.TargetLang='C';
    utilStruct.description.TargetLangStd='Target language standard selection';
    utilStruct.targetInfoStruct.TargetLangStd='C89/C90 (ANSI)';
    utilStruct.description.InstructionSetExtions='Instruction set extensions';
    utilStruct.targetInfoStruct.InstructionSetExtions='None';
    utilStruct.description.PreserveExternInFcnDecls='Preserve extern keyword in function declarations';
    utilStruct.targetInfoStruct.PreserveExternInFcnDecls='on';
    utilStruct.description.ImplementImageWithCVMat='Use cv::Mat to implement image data';
    utilStruct.targetInfoStruct.ImplementImageWithCVMat='off';
    utilStruct.targetInfoStruct.EnableSignedRightShifts='on';
    utilStruct.description.EnableSignedRightShifts='Code Style:: Allow right shifts on signed integers';
    utilStruct.targetInfoStruct.EnableSignedLeftShifts='on';
    utilStruct.description.EnableSignedLeftShifts='Code Style:: Replace multiplications by powers of two with signed bitwise shifts';
    utilStruct.description.TflName='Code Replacement Library Name';
    utilStruct.targetInfoStruct.TflName='';
    utilStruct.description.TflCheckSum='Code Replacement Library Checksum';
    utilStruct.targetInfoStruct.TflCheckSum='';
    utilStruct.description.UtilMemSecPreStatement='Shared Utility Memory Section pre-statement';
    utilStruct.targetInfoStruct.UtilMemSecPreStatement='';
    utilStruct.description.UtilMemSecPostStatement='Shared Utility Memory Section post-statement';
    utilStruct.targetInfoStruct.UtilMemSecPostStatement='';
    utilStruct.description.UtilMemSecComment='Shared Utility Memory Section comment';
    utilStruct.targetInfoStruct.UtilMemSecComment='';

    utilStruct.description.CodeCoverageChecksum='Code coverage settings checksum';
    utilStruct.targetInfoStruct.CodeCoverageChecksum='';
    utilStruct.description.TargetLargestAtomicInteger='Hardware  Impl:: largest atomic integer';
    utilStruct.targetInfoStruct.TargetLargestAtomicInteger='';
    utilStruct.description.TargetLargestAtomicFloat='Hardware  Impl:: largest atomic float';
    utilStruct.targetInfoStruct.TargetLargestAtomicFloat='';
    utilStruct.description.ProdLargestAtomicInteger='Hardware  Impl:: production largest atomic integer';
    utilStruct.targetInfoStruct.ProdLargestAtomicInteger='';
    utilStruct.description.ProdLargestAtomicFloat='Hardware  Impl:: production largest atomic float';
    utilStruct.targetInfoStruct.ProdLargestAtomicFloat='';
    utilStruct.targetInfoStruct.LongLongMode='';
    utilStruct.description.LongLongMode='Hardware  Impl:: enable long long ';
    utilStruct.targetInfoStruct.ProdLongLongMode='';
    utilStruct.description.ProdLongLongMode='Hardware  Impl:: production enable long long ';
end


function outStr=loc_analyze_aliastype(AliasData,baseName)
    outStr=[baseName,': ',AliasData];
    if~isempty(AliasData)
        AliasDataVal=evalin('base',AliasData,'''''');
        if isa(AliasDataVal,'Simulink.AliasType')
            outStr=[outStr,' ',AliasDataVal.Description,' ',AliasDataVal.HeaderFile,' ',AliasDataVal.BaseType];
        end
    end
end


