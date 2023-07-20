function[resultDescription,resultDetails,resultType,hasError,resultId]=checkOptions(systemName,opts)




    if nargin<2
        opts=struct();
    end

    isMdlRef=false;
    if isfield(opts,'isMdlRef')
        isMdlRef=opts.isMdlRef==true;
    end

    disableWarnings=false;
    haltOnWarn=false;
    if isfield(opts,'CheckConfigBeforeAnalysis')
        disableWarnings=strcmpi(opts.CheckConfigBeforeAnalysis,'Off');
        haltOnWarn=strcmpi(opts.CheckConfigBeforeAnalysis,'OnHalt');
    end


    modelName=bdroot(systemName);
    currentCS=getActiveConfigSet(modelName);


    resultDescription={};
    resultDetails={};
    resultType={};
    resultId={};
    hasError=false;
    hasWarning=false;


    resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescGenCodeFolder').getString();
    resultDetails{end+1}={};
    resultType{end+1}={};
    resultId{end+1}={};
    sysDirInfo=pslink.util.Helper.getConfigDirInfo(systemName,pslink.verifier.ec.Coder.CODER_ID);
    if isMdlRef
        codeGenKind='model reference code';
        sysCodeGenDir=sysDirInfo.ModelRefCodeGenDir;
    else
        codeGenKind='code';
        sysCodeGenDir=sysDirInfo.SystemCodeGenDir;
    end

    isERTTarget=strcmpi(get_param(currentCS,'IsERTTarget'),'on');
    if isempty(sysCodeGenDir)||~exist(sysCodeGenDir,'dir')
        resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsGenCodeFolder';
        resultDetails{end}{end+1}=message(resultId{end}{end},codeGenKind,systemName).getString();
        resultType{end}{end+1}='Error';
        hasError=true;
    else
        if~disableWarnings

            codeInfo=[];
            codeInfoFile='codeInfo.mat';
            codeInfoPath=fullfile(sysCodeGenDir,codeInfoFile);

            codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoPath,247362);
            if~isempty(codeDescriptor)
                codeInfo=codeDescriptor.getComponentInterface();
            end

            if~isempty(codeInfo)


                codeChecksum=codeInfo.Checksum;

                if strcmpi(get_param(systemName,'Type'),'block_diagram')
                    errStr='';
                    try


                        [unused,systemChecksum]=evalc('Simulink.BlockDiagram.getChecksum(modelName)');%#ok<ASGLU>





                    catch Me
                        systemChecksum=[];
                        if isempty(Me.cause)
                            errStr=Me.message;
                        else
                            for ii=1:numel(Me.cause)
                                errStr=sprintf('%s%s\n',errStr,Me.cause{ii}.message);
                            end
                        end
                    end

                    if isempty(systemChecksum)
                        resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsCodeFolderNoCkecksum';
                        resultDetails{end}{end+1}=message(resultId{end}{end},errStr).getString();
                        resultType{end}{end+1}='Warning';
                        hasWarning=true;
                    else
                        if systemChecksum~=codeChecksum
                            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsCodeFolderVersionDiff';
                            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
                            resultType{end}{end+1}='Warning';
                            hasWarning=true;
                        end
                    end
                end
            end
        end
    end


    resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescResultsFolder').getString();
    resultDetails{end+1}={};
    resultType{end+1}={};
    resultId{end+1}={};
    psOpts=pslinkoptions(modelName);
    resDir=strrep(psOpts.ResultDir,'$ModelName$',sysDirInfo.SystemCodeGenName);
    if psOpts.AddSuffixToResultDir
        resDir=pssharedprivate('genUniqueDirName',resDir);
    end
    if~exist(resDir,'dir')&&exist(resDir,'file')
        resultId{end}{end+1}='polyspace:gui:pslink:cannotCreateResultsFolder';
        resultDetails{end}{end+1}=message(resultId{end}{end},resDir).getString();
        resultType{end}{end+1}='Error';
        hasError=true;
    end


    resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescCodeGenOpts').getString();
    resultDetails{end+1}={};
    resultType{end+1}={};
    resultId{end+1}={};
    if isERTTarget==0
        if pssharedprivate('isPslinkAvailable')&&pslinkprivate('pslinkattic','getBinMode','allowGrtTarget')
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsGRTTargetUnofficial';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;

            if strcmpi(get_param(currentCS,'GRTInterface'),'on')
                resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsGRTInterface';
                resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
                resultType{end}{end+1}='Error';
                hasError=true;
            end
        else
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsERTTarget';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Error';
            hasError=true;
        end
    end


    bInfoFile=fullfile(sysDirInfo.ModelRefCodeGenDir,'tmwinternal','binfo.mat');
    if exist(bInfoFile,'file')==2
        binfo=load(bInfoFile);
        genCodeLangExt='';
        if isfield(binfo,'infoStruct')&&isfield(binfo.infoStruct,'targetLanguage')
            genCodeLangExt=binfo.infoStruct.targetLanguage;
        end
        modelLang=get_param(modelName,'TargetLang');
        if strncmpi(modelLang,'C++',3)&&strncmpi(genCodeLangExt,'C++',3)
            isSameLanguage=true;
        elseif strcmpi(modelLang,'C')&&strcmpi(genCodeLangExt,'c')
            isSameLanguage=true;
        else
            isSameLanguage=false;
        end
        if~isSameLanguage
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsCLanguage';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Error';
            hasError=true;
        end
    end

    if~disableWarnings
        resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescHWSettings').getString();
        resultDetails{end+1}={};
        resultType{end+1}={};
        resultId{end+1}={};
        [codeTypeInfo,sysTypeInfo]=pssharedprivate('getTypeInfo',systemName,...
        pslink.verifier.ec.Coder.CODER_ID,sysCodeGenDir,sysDirInfo.ModelRefCodeGenDir);
        hwDiff='';
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Device',1,codeTypeInfo.HWDeviceType,sysTypeInfo.HWDeviceType);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for char',0,codeTypeInfo.CharNumBits,sysTypeInfo.CharNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for short',0,codeTypeInfo.ShortNumBits,sysTypeInfo.ShortNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for int',0,codeTypeInfo.IntNumBits,sysTypeInfo.IntNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for long',0,codeTypeInfo.LongNumBits,sysTypeInfo.LongNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for native',0,codeTypeInfo.WordNumBits,sysTypeInfo.WordNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for float',0,codeTypeInfo.FloatNumBits,sysTypeInfo.FloatNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for double',0,codeTypeInfo.DoubleNumBits,sysTypeInfo.DoubleNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Number of bits for pointer',0,codeTypeInfo.PointerNumBits,sysTypeInfo.PointerNumBits);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Byte ordering',1,codeTypeInfo.Endianess,sysTypeInfo.Endianess);
        hwDiff=iGenerateHWDiffMsg(hwDiff,'Shift right on a signed integer as arithmetic shift',0,codeTypeInfo.ShiftRightIntArith,sysTypeInfo.ShiftRightIntArith);
        if~isempty(hwDiff)
            activePage='Hardware Implementation';
            link=sprintf('<a href="matlab:pslinkprivate(''openMdlConfigPrmDlg'',''%s'', ''%s'')">Hardware Implementation</a>',modelName,activePage);
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsHWSettingsVersionDiff';
            resultDetails{end}{end+1}=message(resultId{end}{end},link,hwDiff).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end

        if pssharedprivate('isPslinkAvailable')
            cfgFileName=pslinkprivate('getOrCreateConfigFile',systemName,pslink.verifier.ec.Coder.CODER_ID);
            xmlDoc=pslink.verifier.ConfigFile.readConfigFile(cfgFileName);
            optSetList=polyspace.util.XmlHelper.getNodesList(xmlDoc,'optionset');
            if numel(optSetList)>0
                optSet=optSetList{1};
                tgtOptNode=polyspace.util.XmlHelper.getOrAddNode(optSet,'option',[],'flagname','-target',false);
                currTgtName=char(tgtOptNode.getTextContent());
                if(codeTypeInfo.CharNumBits==32||codeTypeInfo.ShortNumBits==32)&&~(strcmp(currTgtName,'tms320c3x')||strcmp(currTgtName,'sharc21x61'))
                    resultId{end}{end+1}='polyspace:gui:pslink:cannotFillHWSettingsWithSuggestion';
                    resultDetails{end}{end+1}=message(resultId{end}{end},'tms320c3x').getString();
                    resultType{end}{end+1}='Warning';
                    hasWarning=true;
                end
            end
        end

        if codeTypeInfo.PointerNumBits==8
            resultId{end}{end+1}='polyspace:gui:pslink:cannotFillHWSettings';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end


        resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescChkSolver').getString();
        resultDetails{end+1}={};
        resultType{end+1}={};
        resultId{end+1}={};
        currentSolver=get_param(modelName,'Solver');
        if strcmpi(currentSolver,'FixedStepDiscrete')==0
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsChkSolver';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end


        resultDescription{end+1}=message('polyspace:gui:pslink:chkOptsDescCodeGenOptim').getString();
        resultDetails{end+1}={};
        resultType{end+1}={};
        resultId{end+1}={};
        if isERTTarget&&strcmpi(get_param(modelName,'ZeroExternalMemoryAtStartup'),'on')
            activePage='Optimization';
            activeOption='ZeroExternalMemoryAtStartup';
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsZeroExternalMemoryAtStartup';
            resultDetails{end}{end+1}=message(resultId{end}{end},modelName,activePage,activeOption).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end
        if strcmpi(get_param(modelName,'InlineParams'),'off')&&~isMdlRef
            activePage='Optimization';
            details=message('polyspace:gui:pslink:chkOptsDetailsInlineParamsAction9_3').getString();
            activeOption='DefaultParameterBehavior';
            value='Inlined';
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsInlineParams';
            resultDetails{end}{end+1}=message(resultId{end}{end},modelName,activePage,activeOption,value,details).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end
        if strcmpi(get_param(modelName,'InitFltsAndDblsToZero'),'off')
            activeOption='InitFltsAndDblsToZero';
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsInitFltsAndDblsToZero';
            resultDetails{end}{end+1}=message(resultId{end}{end},activeOption).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end

        if strcmpi(get_param(modelName,'MatFileLogging'),'on')
            activeOption='MatFileLogging';
            detail=DAStudio.message('polyspace:gui:pslink:chkOptsDetailsMATFileLogAction');
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsMATFileLog';
            resultDetails{end}{end+1}=message(resultId{end}{end},activeOption,detail).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end

        if strcmpi(get_param(modelName,'GenerateComments'),'off')
            activePage='Comments';
            activeOption='GenerateComments';
            detail=message('polyspace:gui:pslink:chkOptsDetailsGenCommentsAction').getString();
            resultId{end}{end+1}='polyspace:gui:pslink:chkOptsDetailsGenComments';
            resultDetails{end}{end+1}=message(resultId{end}{end},modelName,activePage,activeOption,detail).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end
    end

    if haltOnWarn&&hasWarning
        hasError=true;
    end



    function hwDiff=iGenerateHWDiffMsg(hwDiff,desc,isStr,v1,v2)

        fmt='%d';
        hasDiff=false;
        if isStr
            fmt='%s';
            if~strcmp(v1,v2)
                hasDiff=true;
            end
        else
            if v1~=v2
                hasDiff=true;
            end
        end

        if hasDiff
            fmt=['%s\n%s: ',fmt,' (code) vs. ',fmt,' (model)'];
            hwDiff=sprintf(fmt,hwDiff,desc,v1,v2);
        end



