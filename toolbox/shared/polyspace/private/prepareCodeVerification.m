function packageName=prepareCodeVerification(systemH,pslinkOptions,coderID,isTopMdlRefAnalysis)




    if nargin<4||isempty(isTopMdlRefAnalysis)
        isTopMdlRefAnalysis=false;
    end

    if nargin<3||isempty(coderID)
        coderID=getCoderID(systemH);
    end
    coderName=getCoderName(coderID);


    blocker=SLStudio.internal.ScopedStudioBlocker(message('polyspace:gui:pslink:VerificationRunning').getString());%#ok<NASGU>


    fprintf(1,'### %s\n',message('polyspace:gui:pslink:packAndGoBannerTxt',coderName).getString());


    modelName=getRootModelName(systemH,true);
    systemName=getfullname(systemH);


    if isTopMdlRefAnalysis
        if~strcmp(modelName,systemName)
            error('pslink:badSystemForMdlRefVerif',message('polyspace:gui:pslink:badSystemForMdlRefVerif').getString())
        end
        if~strcmpi(coderID,pslink.verifier.ec.Coder.CODER_ID)
            error('pslink:badCoderForMdlRefVerif',message('polyspace:gui:pslink:badCoderForMdlRefVerif',pslink.verifier.ec.Coder.CODER_NAME).getString())
        end
    end

    if strcmpi(coderID,pslink.verifier.tl.Coder.CODER_ID)&&~isTlInstalled()
        error('pslink:targetLinkNotAvailable',message('polyspace:gui:pslink:targetLinkNotAvailable').getString())
    end


    sysDirInfo=pslink.util.Helper.getConfigDirInfo(systemName,coderID);
    if isTopMdlRefAnalysis
        if isempty(sysDirInfo.ModelRefCodeGenDir)||~isfolder(sysDirInfo.ModelRefCodeGenDir)||...
            ~dirContainsSources(sysDirInfo.ModelRefCodeGenDir)
            error('pslink:noCodeForMdlRefVerif',message('polyspace:gui:pslink:noCodeForMdlRefVerif',systemName,coderName).getString())
        end
    else
        if isempty(sysDirInfo.SystemCodeGenDir)||~exist(sysDirInfo.SystemCodeGenDir,'dir')
            error('pslink:noCodeForSystemVerif',message('polyspace:gui:pslink:noCodeForSystemVerif',systemName,coderName).getString())
        end
        if size(sysDirInfo.AllSystemCodeGenInfo,1)>1
            error('pslink:multiCodeForSystemVerif',message('polyspace:gui:pslink:multiCodeForSystemVerif',systemName).getString())
        end
    end

    if nargin<2||isempty(pslinkOptions)

        pslinkOptions=pslink.Options(modelName);
    end



    pslinkOptions=pslinkOptions.deepCopy();
    pslinkOptions=get(pslinkOptions);


    pslinkOptions.ResultDir=tempname;
    modelNameForResultDir=sysDirInfo.SystemCodeGenName;
    if isTopMdlRefAnalysis
        modelNameForResultDir=['mr_',modelNameForResultDir];
    end
    pslinkOptions.ResultDir=strrep(pslinkOptions.ResultDir,'$ModelName$',modelNameForResultDir);
    pslinkOptions.ResultDir=getOrCreateDir(pslinkOptions.ResultDir);


    sysCdrObj=pslink.verifier.Coder.createCoderObject(coderID,systemName,isTopMdlRefAnalysis);
    verifOptionSetObj=pslink.verifier.OptionSet.createOptionSetObject(coderID);
    verifOptionSetObj.coderObj=sysCdrObj;
    verifOptionSetObj.getTypeInfo(systemName,sysDirInfo);
    verifOptionSetObj.packageName=verifOptionSetObj.getPackageName();


    pslinkOptions.cfgDir=pslinkOptions.ResultDir;


    hasError=verifOptionSetObj.checkConfiguration(systemName,pslinkOptions);
    if hasError
        error('pslink:cannotCreateDir',message('polyspace:gui:pslink:checkOptFailure').getString())
    end


    verifOptionSetObj.printConfiguration(systemName,pslinkOptions);


    extraSrc=[];
    if pslinkOptions.EnableAdditionalFileList
        extraSrc=pslinkOptions.AdditionalFileList;
        if isempty(extraSrc)
            fileName=fullfile(pwd,'polyspace_additional_file_list.txt');
            extraSrc=readAdditionalSourceListFile(fileName);
        end
    end

    extraSrc=extraSrc(:)';


    mdlRefs={};
    if strcmpi(pslinkOptions.ModelRefVerifDepth,'Current model only')
        pslinkOptions.ModelRefByModelRefVerif=false;
    else
        if strcmpi(pslinkOptions.ModelRefVerifDepth,'All')
            stopLevel=inf;
        else
            stopLevel=str2double(pslinkOptions.ModelRefVerifDepth);
        end
        try
            mdlRefs=extractMdlRefs(systemName,stopLevel);
        catch Me %#ok<NASGU>
        end
    end


    nbMdlRefs=numel(mdlRefs);
    if nbMdlRefs==0
        pslinkOptions.ModelRefByModelRefVerif=false;
    end


    sysCdrObj.extractAllInfo(pslinkOptions);
    sysDrsInfo=sysCdrObj.getDataRangeInfo();
    sysFileInfo=sysCdrObj.getFileInfo();
    sysFileInfo.source=RTW.unique([sysFileInfo.source,extraSrc]);
    sysFcnInfo=sysCdrObj.getFcnExecutionInfo();
    sysDataLinkInfo=sysCdrObj.getLinkDataInfo();
    if~isempty(sysDataLinkInfo)&&isstruct(sysDataLinkInfo)


        sysDataLinkInfo.sourcefile=sysFileInfo.source;
    end
    sysARInfo=sysCdrObj.getAutosarInfo();


    mdlRefResultInfo=cell(0,3);
    allMdlRefInfo=cell(0,2);


    oldSysModName=sysCdrObj.sysDirInfo.SystemCodeGenName;
    sysModName=oldSysModName;
    if nbMdlRefs&&pslinkOptions.ModelRefByModelRefVerif
        sysModName=genvarname(sysModName,mdlRefs);
    end
    sysResDir=fullfile(pslinkOptions.ResultDir,sysModName);


    try
        sysResDir=getOrCreateDir(sysResDir);
    catch Me
        warning('pslink:cannotCreateDir',message('polyspace:gui:pslink:cannotCreateDir',strrep(sysResDir,'\','\\'),Me.message).getString());
        fprintf(1,'### %s\n',message('polyspace:gui:pslink:launchVerifSkipAnalysisTxt',sysCdrObj.slSystemName));
        return
    end

    for ii=1:nbMdlRefs

        mdlRefCdrObj=pslink.verifier.Coder.createCoderObject(coderID,mdlRefs{ii},true);

        if isempty(mdlRefCdrObj.cgDir)||~exist(mdlRefCdrObj.cgDir,'dir')
            warning('pslink:noCodeForMdlRefVerif',message('polyspace:gui:pslink:noCodeForMdlRefVerif',mdlRefCdrObj.slModelName,coderName).getString())
            fprintf(1,'### %s\n',message('polyspace:gui:pslink:launchVerifSkipAnalysisTxt',mdlRefCdrObj.slModelName));
            continue
        end


        pslinkOptions.extractLinksDataOnly=true;
        mdlRefCdrObj.extractAllInfo(pslinkOptions);
        pslinkOptions.extractLinksDataOnly=false;
        mdlRefFileInfo=mdlRefCdrObj.getFileInfo();
        mdlRefDataLinkInfo=mdlRefCdrObj.getLinkDataInfo();
        if~isempty(mdlRefDataLinkInfo)&&isstruct(mdlRefDataLinkInfo)


            mdlRefDataLinkInfo.sourcefile=mdlRefFileInfo.source;
        end

        if pslinkOptions.ModelRefByModelRefVerif

            mdlRefCdrObj.extractAllInfo(pslinkOptions);
            mdlRefDrsInfo=mdlRefCdrObj.getDataRangeInfo();
            mdlRefARInfo=mdlRefCdrObj.getAutosarInfo();
            mdlRefFcnInfo=mdlRefCdrObj.getFcnExecutionInfo();


            mdlRefResDir=fullfile(pslinkOptions.ResultDir,mdlRefCdrObj.slModelName);


            try
                mdlRefResDir=getOrCreateDir(mdlRefResDir);
            catch Me
                warning('pslink:cannotCreateDir',message('polyspace:gui:pslink:cannotCreateDir',mdlRefResDir,Me.message));
                fprintf(1,'### %s\n',message('polyspace:gui:pslink:launchVerifSkipAnalysisTxt',mdlRefCdrObj.slModelName));
                continue
            end


            checkSum=mdlRefCdrObj.getCheckSum();
            mdlRefResultInfo=[...
            mdlRefResultInfo;...
            {mdlRefCdrObj.slModelName,mdlRefResDir,checkSum}...
            ];%#ok<AGROW>


            mdlRefFileInfo.source=RTW.unique([mdlRefFileInfo.source,extraSrc]);


            verifOptionSetObj.coderObj=mdlRefCdrObj;
            verifOptionSetObj.mdlRefInfo=cell(0,2);
            verifOptionSetObj.drsInfo=mdlRefDrsInfo;
            verifOptionSetObj.arInfo=mdlRefARInfo;
            verifOptionSetObj.fileInfo=mdlRefFileInfo;
            verifOptionSetObj.fcnInfo=mdlRefFcnInfo;
            verifOptionSetObj.dataLinkInfo=mdlRefDataLinkInfo;
            verifOptionSetObj.resultDir=mdlRefResDir;

            verifOptionSetObj.prepareOptions(pslinkOptions);
            verifOptionSetObj.appendToArchive(pslinkOptions,true);
        else

            allMdlRefInfo=[allMdlRefInfo;{mdlRefCdrObj.slModelName,mdlRefCdrObj.slModelVersion}];%#ok<AGROW>


            sysFileInfo.source=[sysFileInfo.source,mdlRefFileInfo.source];
            sysFileInfo.include=[sysFileInfo.include,mdlRefFileInfo.include];


            sysDataLinkInfo=[sysDataLinkInfo,mdlRefDataLinkInfo];%#ok<AGROW>
        end

    end


    sysFileInfo.source=RTW.unique(sysFileInfo.source);
    sysFileInfo.include=RTW.unique(sysFileInfo.include);


    verifOptionSetObj.coderObj=sysCdrObj;
    verifOptionSetObj.mdlRefInfo=allMdlRefInfo;
    verifOptionSetObj.drsInfo=sysDrsInfo;
    verifOptionSetObj.arInfo=sysARInfo;
    verifOptionSetObj.fileInfo=sysFileInfo;
    verifOptionSetObj.fcnInfo=sysFcnInfo;
    verifOptionSetObj.dataLinkInfo=sysDataLinkInfo;
    verifOptionSetObj.resultDir=sysResDir;

    verifOptionSetObj.prepareOptions(pslinkOptions);
    packageName=verifOptionSetObj.appendToArchive(pslinkOptions,false);

    function hasSources=dirContainsSources(srcDir)
        hasSources=~isempty(dir(fullfile(srcDir,'*.c')))||...
        ~isempty(dir(fullfile(srcDir,'*.h')))||...
        ~isempty(dir(fullfile(srcDir,'*.cpp')));



