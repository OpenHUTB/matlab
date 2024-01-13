classdef Coder<pslink.verifier.Coder

    properties(Constant,GetAccess=public)
        CODER_NAME='Embedded Coder';
        CODER_ID='ec';
        CODER_VERIF_NAME='RTWEmbeddedCoder';
        CODER_IDE_NAME='EmbeddedCoder';
    end

    properties(Hidden=true,SetAccess=protected,GetAccess=public)
buildInfo
traceInfo
expInports
cgLanguage
cgStdLang
sharedCodeManager
    end


    methods(Access=public)

        function self=Coder(slSystemName,isMdlRef)
            if nargin<2
                isMdlRef=false;
            end
            self=self@pslink.verifier.Coder(slSystemName,isMdlRef);

            self.buildInfo=[];
            self.traceInfo=[];
            self.expInports=[];
            self.mustWriteAllData=false;
            self.booleanTypes=[];
            self.fcnToStub=[];
            self.sysDirInfo=pslink.util.Helper.getConfigDirInfo(self.slSystemName,pslink.verifier.ec.Coder.CODER_ID);
            self.cgName=self.sysDirInfo.SystemCodeGenName;
            if isMdlRef
                self.cgDir=self.sysDirInfo.ModelRefCodeGenDir;
            else
                self.cgDir=self.sysDirInfo.SystemCodeGenDir;
            end
            self.cgDirStatus=exist(self.cgDir,'dir');
            self.cgLanguage=self.getCodeLang();
            self.cgStdLang=self.getLangStandard();
            self.sharedCodeManager=[];

            self.inputFullRange=true;
            self.outputFullRange=true;
            self.paramFullRange=true;

        end


        function checkSum=getCheckSum(self)
            checkSum=[];
            self.loadCodeInfo();
            if~isempty(self.codeInfo)
                checkSum=self.codeInfo.Checksum();
            end
        end


        function extractAllInfo(self,pslinkOptions)
            if nargin<2
                pslinkOptions=pslink.Options();
                pslinkOptions=get(pslinkOptions);
                pslinkOptions.InputRangeMode='DesignMinMax';
                pslinkOptions.OutputRangeMode='None';
                pslinkOptions.ParamRangeMode='None';
                pslinkOptions.extractLinksDataOnly=false;
            else
                if~isfield(pslinkOptions,'extractLinksDataOnly')
                    pslinkOptions.extractLinksDataOnly=false;
                end
            end

            if strcmpi(pslinkOptions.InputRangeMode,'DesignMinMax')
                self.inputFullRange=false;
            end
            if strcmpi(pslinkOptions.OutputRangeMode,'DesignMinMax')
                self.outputFullRange=false;
            end
            if strcmpi(pslinkOptions.ParamRangeMode,'DesignMinMax')
                self.paramFullRange=false;
            end

            if self.cgDirStatus
                traceInfoFile=fullfile(self.cgDir,'html','traceInfo.mat');

                if exist(traceInfoFile,'file')~=2
                    currentFolder=pwd;
                    try
                        rptObj=rtw.report.getReportInfo(self.slSystemName);
                        rptObj.generate('GenerateTraceInfo','on');
                    catch Me %#ok<NASGU>
                    end

                    cd(currentFolder);
                end
                if exist(traceInfoFile,'file')==2
                    matFile=load(traceInfoFile);
                    if isfield(matFile,'infoStruct')&&isfield(matFile.infoStruct,'traceInfo')
                        if isfield(matFile.infoStruct.traceInfo,'name')&&...
                            isfield(matFile.infoStruct.traceInfo,'rtwname')&&...
                            isfield(matFile.infoStruct.traceInfo,'pathname')
                            self.traceInfo=matFile.infoStruct.traceInfo;
                        end
                    end
                end
            end
            if~isempty(self.traceInfo)
                self.dlinkInfo.name=self.slModelName;
                self.dlinkInfo.source='traceInfo';
                self.dlinkInfo.model=self.slModelFileName;
                self.dlinkInfo.version=self.slModelVersion;
                self.dlinkInfo.info(1:numel(self.traceInfo))=pslink.verifier.Coder.createLinkDataInfoStruct();
                for ii=1:numel(self.traceInfo)
                    self.dlinkInfo.info(ii).name=self.traceInfo(ii).name;
                    self.dlinkInfo.info(ii).codename=self.traceInfo(ii).rtwname;
                    self.dlinkInfo.info(ii).path=self.traceInfo(ii).pathname;
                    self.dlinkInfo.info(ii).sid=self.traceInfo(ii).sid;
                end

                try
                    traceData=coder.trace.getTraceInfo(self.slSystemName);
                    if~isempty(traceData)
                        tracedFiles=traceData.files;
                        records=traceData.getCodeToModelRecords;
                        rptObj=rtw.report.getReportInfo(self.slSystemName);
                        self.dlinkInfo.ctmRec(1:numel(records))=pslink.verifier.Coder.createCodeToModelInfoStruct();
                        for ii=1:numel(records)
                            self.dlinkInfo.ctmRec(ii).sid=records(ii).modelElems;

                            if~isempty(rptObj.SourceSubsystem)
                                self.dlinkInfo.ctmRec(ii).sid{1}=Simulink.ID.getSubsystemBuildSID(self.dlinkInfo.ctmRec(ii).sid{1},rptObj.SourceSubsystem);
                            end
                            self.dlinkInfo.ctmRec(ii).token=records(ii).token.token;
                            self.dlinkInfo.ctmRec(ii).file=tracedFiles{records(ii).token.fileIdx+1};
                            self.dlinkInfo.ctmRec(ii).line=records(ii).token.line;
                            self.dlinkInfo.ctmRec(ii).beginCol=records(ii).token.beginCol;
                        end
                    else
                        self.dlinkInfo.ctmRec=[];
                    end
                catch Me %#ok<NASGU>
                    self.dlinkInfo.ctmRec=[];
                end
            end

            if pslinkOptions.extractLinksDataOnly
                addExtraInfoToCodeInfo(self,true);
            else
                self.getBooleanType();
                self.getFcnToStub();
                self.loadCodeInfo();
                self.fcnInfo.codeLanguage=self.cgLanguage;
                addExtraInfoToCodeInfo(self,false);

                if~isempty(self.codeInfo)
                    if~self.hasInternalError
                        fillDataRangeInfo(self);
                    end

                    if~isempty(self.arInfo)&&~isempty(self.arInfo.compName)

                        if pslinkprivate('pslinkattic','getBinMode','autosarFinalAssert')
                            generateARStubs(self,pslinkOptions);
                        end
                        self.booleanTypes=[self.booleanTypes,{'Boolean'}];
                    end
                    [execMap,className]=extractExecutionInfo(self,[]);
                    fillFcnInfo(self,execMap,className);

                    self.fcnInfo.mustWriteAllData=self.mustWriteAllData;
                else
                    self.fcnInfo.mustWriteAllData=true;
                end
            end
        end


        function fileInfo=getFileInfo(self,opts)

            if nargin<2
                opts=struct('includeMdlRefs',false);
            else
                if~isfield(opts,'includeMdlRefs')
                    opts.includeMdlRefs=false;
                end
            end

            self.loadBuildInfo();
            self.loadSharedCodeManager();
            if~isempty(self.buildInfo)
                fillFileInfo(self,opts);
            end

            fileInfo=self.fileInfo;
        end


        function dlinkInfo=getLinkDataInfo(self)
            dlinkInfo=self.dlinkInfo;
        end


        function booleanTypes=getBooleanType(self)

            configSet=self.getConfigSet();
            if configSet.isValidParam('ReplacementTypes')&&strcmpi(get_param(configSet,'EnableUserReplacementTypes'),'on')
                replTypes=get_param(configSet,'ReplacementTypes');
                booleanTypeValue=replTypes.boolean;
                if~isempty(booleanTypeValue)
                    self.booleanTypes{end+1}=booleanTypeValue;
                end
            end
            booleanTypes=self.booleanTypes;

        end


        function fcnToStub=getFcnToStub(self)

            configSet=self.getConfigSet();
            if configSet.isValidParam('SupportNonFinite')&&configSet.isValidParam('PurelyIntegerCode')&&...
                (strcmpi(get_param(configSet,'SupportNonFinite'),'on')||strcmpi(get_param(configSet,'PurelyIntegerCode'),'off'))

                self.fcnToStub={...
                'rtIsNaN',...
                'rtIsInf',...
                'rtIsNaNF',...
'rtIsInfF'...
                };
            end
            fcnToStub=self.fcnToStub;
        end

    end


    methods(Access=private)

        function loadCodeInfo(self)
            if self.cgDirStatus
                if(self.buildFailed())
                    error('codedescriptor:core:ModelBuildFailed',...
                    DAStudio.message('codedescriptor:core:ModelBuildFailed',...
                    self.slModelName));
                end
                codeDescriptor=coder.internal.getCodeDescriptorInternal(self.cgDir,self.slModelName,247362);
                if~isempty(codeDescriptor)
                    localCodeInfo=codeDescriptor.getComponentInterface();
                    if~isempty(localCodeInfo)&&isa(localCodeInfo,'RTW.ComponentInterface')
                        self.codeInfo=localCodeInfo;
                        self.expInports=codeDescriptor.getExpInports();
                    end
                end
            end
        end


        function configSet=getConfigSet(self)
            configSet=getActiveConfigSet(self.slModelName);

            bInfo=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal','binfo.mat');
            if~exist(bInfo,'file')
                bInfo=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal','binfo_mdlref.mat');
            end
            if exist(bInfo,'file')
                try
                    rtwTypeInfo=load(bInfo);
                    codeGenConfigSet=rtwTypeInfo.infoStructConfigSet;
                catch Me %#ok<NASGU>
                    return
                end
                configSet=codeGenConfigSet;
            end
        end


        function ai=getAutosarInterface(self)
            ai=[];
            try
                if strcmp(self.slModelName,self.slSystemName)
                    ai=get_param(self.slModelName,'RTWFcnClass');
                else
                    ai=get_param(self.slSystemName,'SSRTWFcnClass');
                end
                if~isa(ai,'RTW.AutosarInterface')
                    ai=[];
                end
            catch Me %#ok<NASGU>

            end
        end


        function codeLang=getCodeLang(self)
            codeLang='';
            bInfoFile=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal','binfo.mat');
            if~exist(bInfoFile,'file')
                bInfoFile=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal','binfo_mdlref.mat');
            end
            if exist(bInfoFile,'file')==2
                try
                    binfo=load(bInfoFile);
                    if isfield(binfo,'infoStruct')&&isfield(binfo.infoStruct,'targetLanguage')
                        codeLang=binfo.infoStruct.targetLanguage;
                    end
                catch Me %#ok<NASGU>
                    return
                end
            end

            self.loadBuildInfo();
            if~isempty(self.buildInfo)
                [~,codeInterface]=self.buildInfo.findTMFToken('|>CODE_INTERFACE_PACKAGING<|');
                if~isempty(codeInterface)&&strcmpi(codeInterface,'C++ class')
                    codeLang='C++ (Encapsulated)';
                end
            end
        end


        function out=findBInfoMInfoMAT(self,fileName)
            infoFile=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal',fileName);
            out=isfile(infoFile);
        end


        function out=buildFailed(self)
            bInfoExists=findBInfoMInfoMAT(self,'binfo.mat')||...
            findBInfoMInfoMAT(self,'binfo_mdlref.mat');
            mInfoExists=findBInfoMInfoMAT(self,'minfo.mat')||...
            findBInfoMInfoMAT(self,'minfo_mdlref.mat');

            if bInfoExists&&mInfoExists
                out=false;
                return;
            end
            out=true;
        end


        function langStd=getLangStandard(self)
            langStd='';

            configSet=self.getConfigSet();
            if configSet.isValidParam('TargetLangStandard')
                langStd=get_param(configSet,'TargetLangStandard');

                if strncmpi(self.cgLanguage,'C++',3)

                    switch langStd
                    case 'C++11 (ISO)'
                        langStd='cpp11';
                    case 'C++03 (ISO)'
                        langStd='cpp03';
                    otherwise
                        langStd='cpp11';
                    end
                else
                    switch langStd
                    case 'C99 (ISO)'
                        langStd='c99';
                    case 'C89/C90 (ANSI)'
                        langStd='c90';
                    otherwise
                        langStd='c99';
                    end
                end
            end
        end


        function loadBuildInfo(self)
            candidates={...
            'binfo.mat',...
            'binfo_mdlref.mat',...
            'minfo.mat',...
'minfo_mdlref.mat'...
            };

            for ii=1:numel(candidates)
                bInfoFile=fullfile(self.sysDirInfo.ModelRefCodeGenDir,'tmwinternal',candidates{ii});
                if exist(bInfoFile,'file')
                    break
                end
            end

            codeVersion='';
            if exist(bInfoFile,'file')==2
                try
                    binfo=load(bInfoFile);
                    if isfield(binfo,'infoStruct')&&isfield(binfo.infoStruct,'mVersion')
                        codeVersion=binfo.infoStruct.mVersion;
                    end
                catch Me
                    error('pslink:unsupportedCodeVersion',DAStudio.message('polyspace:gui:pslink:unsupportedCodeVersion'));
                end
            end
            if~strcmpi(version,codeVersion)
                error('pslink:unsupportedCodeVersion',DAStudio.message('polyspace:gui:pslink:unsupportedCodeVersion'));
            end

            if self.cgDirStatus
                buildInfoFile=coder.internal.rte.SDPTypes.getBuildInfoFile(self.slModelName,self.cgDir);
                if exist(buildInfoFile,'file')==2
                    matFile=load(buildInfoFile);
                    if isfield(matFile,'buildInfo')&&isa(matFile.buildInfo,'RTW.BuildInfo')
                        self.buildInfo=matFile.buildInfo;
                    end
                end
            end
        end


        function loadSharedCodeManager(self)
            sharedFile=fullfile(self.sysDirInfo.SharedUtilsDir,'shared_file.dmr');
            scm='';
            if exist(sharedFile,'file')
                scm=SharedCodeManager.SharedCodeManagerInterface(sharedFile);
            end

            clrObj=onCleanup(@()ncleanup());

            if~isempty(scm)
                self.sharedCodeManager=scm.retrieveAllData('SCM_UTILITIES');
            else

                self.sharedCodeManager=[];
            end

            function ncleanup()
                clear scm;
            end
        end
    end


    methods(Static=true)
        [resultDescription,resultDetails,resultType,hasError,resultId]=checkOptions(systemName,opts)
        cgDirInfo=getCodeGenerationDir(systemName)


        function str=getCoderName()
            str=pslink.verifier.ec.Coder.CODER_NAME;
        end


        function str=getCoderVersion()
            str=ver('embeddedcoder');
        end

    end


    methods(Static=true,Access=private)

        function addAllDynamicProperties(uddObj)
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'MinMax','mxArray',{[],[]});
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'BlkMinMax','mxArray',{[],[]});
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'SLObj','mxArray',[]);
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'FromModel','bool',true);
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'UsageKind','int32',0);
            pslink.verifier.ec.Coder.addDynamicProperty(uddObj,'isFullDataTypeRange','bool',false);
        end


        function addDynamicProperty(uddObj,propName,propType,defaultValue)%#ok<INUSL>
            if~isprop(uddObj,propName)
                prop=addprop(uddObj,propName);
                prop.Hidden=true;
                uddObj.(propName)=defaultValue;
            end
        end
    end


    methods(Static=true)

        function embeddedObj=getUnderlyingType(embeddedObj)
            embeddedObj=pslink.verifier.ec.Coder.getCoderType(embeddedObj);
            if isa(embeddedObj,'embedded.matrixtype')||isa(embeddedObj,'embedded.pointertype')
                embeddedObj=pslink.verifier.ec.Coder.getUnderlyingType(embeddedObj.BaseType);
            end
        end


        function embeddedObj=getCoderType(embeddedObj)
            if isa(embeddedObj,'coder.types.Type')
                embeddedObj=embeddedObj.getEmbeddedType;
            end
        end


        function ret=embeddedTypeIsFixedPoint(embeddedObj)
            embeddedObj=pslink.verifier.ec.Coder.getCoderType(embeddedObj);
            assert(isa(embeddedObj,'embedded.type'),'Argument must be an embedded.type object.');

            ret=false;
            if isa(embeddedObj,'embedded.matrixtype')||isa(embeddedObj,'embedded.pointertype')
                ret=pslink.verifier.ec.Coder.embeddedTypeIsFixedPoint(embeddedObj.BaseType);
            elseif isnumerictype(embeddedObj)
                if strcmpi(embeddedObj.DataType,'fixed')&&...
                    (embeddedObj.Slope~=1||embeddedObj.Bias~=0)
                    ret=true;
                end
            else

            end
        end


        function dtRange=getDataTypeRange(embeddedObj,useRawValue)
            embeddedObj=pslink.verifier.ec.Coder.getCoderType(embeddedObj);
            assert(isa(embeddedObj,'embedded.type'),'Argument must be an embedded.type object.');

            if nargin<2
                useRawValue=false;
            end

            dtRange={[],[]};

            if isa(embeddedObj,'embedded.enumtype')
                enumVal=double(embeddedObj.Values);
                dtRange={double(min(enumVal)),double(max(enumVal))};

            elseif isnumerictype(embeddedObj)
                switch lower(embeddedObj.DataType)
                case{'double','single'}
                    dtRange={-inf,inf};

                case 'boolean'
                    dtRange={0,1};

                case 'fixed'
                    if(embeddedObj.Slope~=1||embeddedObj.Bias~=0)
                        tmpObj=fi(0,embeddedObj);
                        if useRawValue
                            dtRange={double(tmpObj.intmin()),double(tmpObj.intmax())};
                        else
                            dtRange={double(tmpObj.realmin()),double(tmpObj.realmax())};
                        end
                    end

                otherwise

                end

            elseif isa(embeddedObj,'embedded.matrixtype')||isa(embeddedObj,'embedded.pointertype')
                dtRange=pslink.verifier.ec.Coder.getDataTypeRange(embeddedObj.BaseType,useRawValue);
            else

            end
        end


        function minMax=computeDataMinMax(data,type,minVal,maxVal)
            type=pslink.verifier.ec.Coder.getCoderType(type);

            [badMinOrMax,badMin,badMax]=pslink.util.SimulinkHelper.hasMissingMinMaxValues(minVal,maxVal);
            try
                bottomType=pslink.verifier.ec.Coder.getUnderlyingType(type);
                isFixedPoint=pslink.verifier.ec.Coder.embeddedTypeIsFixedPoint(bottomType);
                isGoodType=true;
            catch Me %#ok
                isGoodType=false;
            end

            if~isGoodType
                minVal=[];
                maxVal=[];
            else

                if~isempty(data)&&badMin&&badMax
                    minVal=[];
                    maxVal=[];
                end

                dtRange=[];
                if badMinOrMax&&~isFixedPoint
                    dtRange=pslink.verifier.ec.Coder.getDataTypeRange(type,true);
                end

                if~badMin
                    if isFixedPoint

                        fxpt=fi(minVal,bottomType);
                        minVal=fxpt.int();
                    elseif badMax
                        maxVal=dtRange{2};
                    end
                end
                if~badMax
                    if isFixedPoint

                        fxpt=fi(maxVal,bottomType);
                        maxVal=fxpt.int();
                    elseif badMin
                        minVal=dtRange{1};
                    end
                end
            end

            minMax={minVal,maxVal};
        end
    end

end



