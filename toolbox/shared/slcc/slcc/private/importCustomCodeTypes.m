function importResults=importCustomCodeTypes(headerFiles,varargin)



    importResults=[];
    params=parseTypeImporterParams(headerFiles,varargin{:});


    if isempty(params.headerFiles)
        return;
    end




    isHostCompiler=strcmp(params.HardwareImplementation.ProdHWDeviceType,...
    params.hostHardwareImplementation.ProdHWDeviceType);

    feOptions=internal.cxxfe.util.getFrontEndOptions('lang',params.Language,...
    'useMexSettings',isHostCompiler,'addMWInc',true,'forceLcc64',false);

    feOptions.Preprocessor.UnDefines=[feOptions.Preprocessor.UnDefines(:);params.UnDefines];
    feOptions.Preprocessor.Defines=[feOptions.Preprocessor.Defines(:);params.Defines];
    feOptions.Preprocessor.IncludeDirs=[feOptions.Preprocessor.IncludeDirs(:);pwd;params.IncludeDirs];

    [feOptions,algorithmWordSizes,targetWordSizes]=applyHardwareSizes(feOptions,params);
    checksum=getChecksumFromCode(params.headerFiles,params.ImportAllTypes,feOptions,algorithmWordSizes,targetWordSizes);
    importedTypes=slcc('importCustomCodeTypes',params.headerFiles,params,feOptions,checksum,algorithmWordSizes,targetWordSizes);

    importResults=createCustomCodeTypeObjects(importedTypes,params);


    function[feOptions,algorithmWordSizes,targetWordSizes]=applyHardwareSizes(feOptions,params)


        algorithmWordSizes.CharNumBits=params.HardwareImplementation.ProdBitPerChar;
        algorithmWordSizes.ShortNumBits=params.HardwareImplementation.ProdBitPerShort;
        algorithmWordSizes.IntNumBits=params.HardwareImplementation.ProdBitPerInt;
        algorithmWordSizes.LongNumBits=params.HardwareImplementation.ProdBitPerLong;
        algorithmWordSizes.LongLongNumBits=params.HardwareImplementation.ProdBitPerLongLong;
        algorithmWordSizes.FloatNumBits=params.HardwareImplementation.ProdBitPerFloat;
        algorithmWordSizes.DoubleNumBits=params.HardwareImplementation.ProdBitPerDouble;
        algorithmWordSizes.LongDoubleNumBits=params.HardwareImplementation.ProdBitPerLongLong;
        algorithmWordSizes.PointerNumBits=params.HardwareImplementation.ProdBitPerPointer;


        targetWordSizes.CharNumBits=params.hostHardwareImplementation.ProdBitPerChar;
        targetWordSizes.ShortNumBits=params.hostHardwareImplementation.ProdBitPerShort;
        targetWordSizes.IntNumBits=params.hostHardwareImplementation.ProdBitPerInt;
        targetWordSizes.LongNumBits=params.hostHardwareImplementation.ProdBitPerLong;
        targetWordSizes.LongLongNumBits=params.hostHardwareImplementation.ProdBitPerLongLong;
        targetWordSizes.FloatNumBits=params.hostHardwareImplementation.ProdBitPerFloat;
        targetWordSizes.DoubleNumBits=params.hostHardwareImplementation.ProdBitPerDouble;
        targetWordSizes.LongDoubleNumBits=params.hostHardwareImplementation.ProdBitPerLongLong;
        targetWordSizes.PointerNumBits=params.hostHardwareImplementation.ProdBitPerPointer;


        feOptions.Target.CharNumBits=algorithmWordSizes.CharNumBits;
        feOptions.Target.ShortNumBits=algorithmWordSizes.ShortNumBits;
        feOptions.Target.IntNumBits=algorithmWordSizes.IntNumBits;
        feOptions.Target.LongNumBits=algorithmWordSizes.LongNumBits;
        feOptions.Target.LongLongNumBits=algorithmWordSizes.LongLongNumBits;
        feOptions.Target.FloatNumBits=algorithmWordSizes.FloatNumBits;
        feOptions.Target.DoubleNumBits=algorithmWordSizes.DoubleNumBits;
        feOptions.Target.LongDoubleNumBits=algorithmWordSizes.LongDoubleNumBits;
        feOptions.Target.PointerNumBits=algorithmWordSizes.PointerNumBits;


        function checksum=getChecksumFromCode(headerFiles,importAllTypes,feOptions,algorithmWordSizes,targetWordSizes)
            chkMgr=CGXE.CustomCode.CheckSumManager(feOptions);
            checksum=chkMgr.computeCheckSum([],headerFiles,false);

            checksum=CGXE.Utils.md5(checksum,pwd);

            checksum=CGXE.Utils.md5(checksum,algorithmWordSizes,targetWordSizes);

            checksum=CGXE.Utils.md5(checksum,importAllTypes);

            checksum=chkMgr.computeCompilerCheckSum(checksum);
            checksum=cgxe('MD5AsString',checksum);
