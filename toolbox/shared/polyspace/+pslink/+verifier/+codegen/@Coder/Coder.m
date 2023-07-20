classdef Coder<pslink.verifier.Coder





    properties(Constant,GetAccess=public)
        CODER_NAME='MATLAB Coder';
        CODER_ID='codegen';
        CODER_VERIF_NAME='MATLABCODER';
        CODER_IDE_NAME='MATLABCODER';
    end

    properties(Hidden=true,SetAccess=protected,GetAccess=public)
buildInfo
configInfo
traceInfo
cgLanguage
cgStdLang
supportNonFinite
    end

    methods(Access=public)




        function self=Coder(codeGenFolder)

            self=self@pslink.verifier.Coder('-codegenfolder',codeGenFolder);

            self.buildInfo=[];
            self.configInfo=[];
            self.traceInfo=[];
            self.mustWriteAllData=false;
            self.booleanTypes=[];
            self.fcnToStub=[];

            self.sysDirInfo=pslink.util.Helper.getConfigDirInfo('-codegenfolder',pslink.verifier.codegen.Coder.CODER_ID,codeGenFolder);
            self.cgName=self.sysDirInfo.SystemCodeGenName;

            self.cgDir=codeGenFolder;

            self.cgDirStatus=exist(self.cgDir,'dir');
            self.cgLanguage=self.getCodeLang();
            self.cgStdLang=self.getLangStandard();
            self.supportNonFinite=self.getNonfiniteSupportState();

        end




        function checkSum=getCheckSum(self)
            checkSum=[];
            self.loadCodeInfo();
            if~isempty(self.codeInfo)
                checkSum=self.codeInfo.Checksum();
            end
        end





        function extractAllInfo(self,~)

            self.fcnInfo.codeLanguage=self.cgLanguage;
            self.getFcnToStub();
            self.getBooleanType();

            if~isempty(self.codeInfo)&&~isempty(self.configInfo)

                [execMap,className]=extractExecutionInfo(self,[]);
                fillFcnInfo(self,execMap,className);

                self.fcnInfo.mustWriteAllData=self.mustWriteAllData;
            else
                self.fcnInfo.mustWriteAllData=true;
            end
        end






        function extractDrsInfo(self,pslinkOptions)
            if nargin<2
                pslinkOptions=pslink.Options();
                pslinkOptions=get(pslinkOptions);
                pslinkOptions.InputRangeMode='DesignMinMax';
                pslinkOptions.OutputRangeMode='None';
                pslinkOptions.ParamRangeMode='None';
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

            self.loadCodeInfo();
            addExtraInfoToCodeInfo(self);

            if~isempty(self.codeInfo)
                if~self.hasInternalError
                    fillDataRangeInfo(self);
                end
            end
        end





        function fileInfo=getFileInfo(self,opts)%#ok<INUSD>
            self.loadBuildInfo();
            if~isempty(self.buildInfo)
                fillFileInfo(self);
            end

            fileInfo=self.fileInfo;
        end





        function dlinkInfo=getLinkDataInfo(self)
            dlinkInfo=self.dlinkInfo;
        end




        function booleanTypes=getBooleanType(self)
            self.booleanTypes={};
            booleanTypes=self.booleanTypes;
        end




        function fcnToStub=getFcnToStub(self)
            self.fcnToStub={...
            'rtIsNaN',...
            'rtIsInf',...
            'rtIsNaNF',...
'rtIsInfF'...
            };
            fcnToStub=self.fcnToStub;
        end




        function codeLang=getCodeLang(self)
            codeLang='';

            self.loadCodeInfo();
            if~isempty(self.configInfo)
                codeLang=self.configInfo.TargetLang;
            end

            if strcmpi(self.configInfo.TargetLang,'C++')...
                &&isprop(self.configInfo,'CppInterfaceStyle')...
                &&strcmpi(self.configInfo.CppInterfaceStyle,'Methods')
                codeLang='C++ (Encapsulated)';
            end
        end




        function langStd=getLangStandard(self)
            langStd='';

            self.loadCodeInfo();
            if~isempty(self.configInfo)
                langStd=emlcprivate('getActualTargetLangStandard',...
                self.configInfo);

                if strcmpi(self.configInfo.TargetLang,'C++')


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





        function isSupported=getNonfiniteSupportState(self)
            isSupported=false;

            self.loadCodeInfo();
            if~isempty(self.configInfo)
                isSupported=self.configInfo.SupportNonFinite;
            end
        end




        function hardwareInfo=getHWInfo(self)
            self.loadCodeInfo();
            if~isempty(self.configInfo)
                hardwareInfo.IsCharSigned=true;
                if strcmpi(self.configInfo.HardwareImplementation.ProdEqTarget,'true')
                    hardwareInfo.CharNumBits=self.configInfo.HardwareImplementation.ProdBitPerChar;
                    hardwareInfo.ShortNumBits=self.configInfo.HardwareImplementation.ProdBitPerShort;
                    hardwareInfo.IntNumBits=self.configInfo.HardwareImplementation.ProdBitPerInt;
                    hardwareInfo.LongNumBits=self.configInfo.HardwareImplementation.ProdBitPerLong;
                    hardwareInfo.LongLongNumBits=self.configInfo.HardwareImplementation.ProdBitPerLongLong;
                    hardwareInfo.FloatNumBits=self.configInfo.HardwareImplementation.ProdBitPerFloat;
                    hardwareInfo.DoubleNumBits=self.configInfo.HardwareImplementation.ProdBitPerDouble;
                    hardwareInfo.LongDoubleNumBits=self.configInfo.HardwareImplementation.ProdBitPerDouble;
                    hardwareInfo.WordNumBits=self.configInfo.HardwareImplementation.ProdWordSize;
                    hardwareInfo.PointerNumBits=self.configInfo.HardwareImplementation.ProdBitPerPointer;
                    hardwareInfo.ShiftRightIntArith=self.configInfo.HardwareImplementation.ProdShiftRightIntArith;
                    hardwareInfo.Endianess=self.configInfo.HardwareImplementation.ProdEndianess;
                    hardwareInfo.HWDeviceType=self.configInfo.HardwareImplementation.ProdHWDeviceType;
                    if isprop(self.configInfo.HardwareImplementation,'ProdWordSize')
                        hardwareInfo.WordNumBits=self.configInfo.HardwareImplementation.ProdWordSize;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'ProdBitPerPointer')
                        hardwareInfo.PointerNumBits=self.configInfo.HardwareImplementation.ProdBitPerPointer;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'ProdBitPerFloat')
                        hardwareInfo.FloatNumBits=self.configInfo.HardwareImplementation.ProdBitPerFloat;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'ProdBitPerDouble')
                        hardwareInfo.DoubleNumBits=self.configInfo.HardwareImplementation.ProdBitPerDouble;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'ProdBitPerDouble')
                        hardwareInfo.LongDoubleNumBits=self.configInfo.HardwareImplementation.ProdBitPerDouble;
                    end
                else
                    hardwareInfo.CharNumBits=self.configInfo.HardwareImplementation.TargetBitPerChar;
                    hardwareInfo.ShortNumBits=self.configInfo.HardwareImplementation.TargetBitPerShort;
                    hardwareInfo.IntNumBits=self.configInfo.HardwareImplementation.TargetBitPerInt;
                    hardwareInfo.LongNumBits=self.configInfo.HardwareImplementation.TargetBitPerLong;
                    hardwareInfo.LongLongNumBits=self.configInfo.HardwareImplementation.TargetBitPerLongLong;
                    hardwareInfo.FloatNumBits=self.configInfo.HardwareImplementation.TargetBitPerFloat;
                    hardwareInfo.DoubleNumBits=self.configInfo.HardwareImplementation.TargetBitPerDouble;
                    hardwareInfo.LongDoubleNumBits=self.configInfo.HardwareImplementation.TargetBitPerDouble;
                    hardwareInfo.WordNumBits=self.configInfo.HardwareImplementation.TargetWordSize;
                    hardwareInfo.PointerNumBits=self.configInfo.HardwareImplementation.TargetBitPerPointer;
                    hardwareInfo.ShiftRightIntArith=self.configInfo.HardwareImplementation.TargetShiftRightIntArith;
                    hardwareInfo.Endianess=self.configInfo.HardwareImplementation.TargetEndianess;
                    hardwareInfo.HWDeviceType=self.configInfo.HardwareImplementation.TargetHWDeviceType;
                    if isprop(self.configInfo.HardwareImplementation,'TargetWordSize')
                        hardwareInfo.WordNumBits=self.configInfo.HardwareImplementation.TargetWordSize;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'TargetBitPerPointer')
                        hardwareInfo.PointerNumBits=self.configInfo.HardwareImplementation.TargetBitPerPointer;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'TargetBitPerFloat')
                        hardwareInfo.FloatNumBits=self.configInfo.HardwareImplementation.TargetBitPerFloat;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'TargetBitPerDouble')
                        hardwareInfo.DoubleNumBits=self.configInfo.HardwareImplementation.TargetBitPerDouble;
                    end
                    if isprop(self.configInfo.HardwareImplementation,'TargetBitPerDouble')
                        hardwareInfo.LongDoubleNumBits=self.configInfo.HardwareImplementation.TargetBitPerDouble;
                    end
                end
            end
        end
    end

    methods(Access=private)



        function loadCodeInfo(self)
            if self.cgDirStatus
                codeInfoFile=fullfile(self.cgDir,'codeInfo.mat');
                codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoFile,247362);
                if~isempty(codeDescriptor)
                    localCodeInfo=codeDescriptor.getComponentInterface();
                    localConfigInfo=codeDescriptor.getConfigInfo();
                    if~isempty(localCodeInfo)&&~isempty(localConfigInfo)&&isa(localCodeInfo,'RTW.ComponentInterface')
                        self.codeInfo=localCodeInfo;
                        self.configInfo=localConfigInfo;
                    end
                end
            end
        end




        function loadBuildInfo(self)
            if self.cgDirStatus
                buildInfoFile=fullfile(self.cgDir,'buildInfo.mat');
                if exist(buildInfoFile,'file')==2
                    matFile=load(buildInfoFile);
                    if isfield(matFile,'buildInfo')&&isa(matFile.buildInfo,'RTW.BuildInfo')
                        self.buildInfo=matFile.buildInfo;
                    end
                end
            end
        end
    end

    methods(Static=true)
        [resultDescription,resultDetails,resultType,hasError,resultId]=checkOptions(codeGenFolder,opts)




        function str=getCoderName()
            str=pslink.verifier.codegen.Coder.CODER_NAME;
        end




        function str=getCoderVersion()
            str=ver('embeddedcoder');
        end





        function codegenID=getCodegenID(codeGenFolder)
            codegenID='';
            codeInfo=[];
            codeInfoFile=fullfile(codeGenFolder,'codeInfo.mat');

            codeDescriptor=coder.getCodeDescriptor(codeInfoFile);
            if~isempty(codeDescriptor)
                codeInfo=codeDescriptor.getComponentInterface();
            end

            if~isempty(codeInfo)&&isa(codeInfo,'RTW.ComponentInterface')
                codegenID=codeInfo.Name;
            end
        end

    end

    methods(Static=true,Access=private)


        function addAllDynamicProperties(uddObj)
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'MinMax','mxArray',{[],[]});
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'BlkMinMax','mxArray',{[],[]});
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'SLObj','mxArray',[]);
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'FromModel','bool',true);
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'UsageKind','int32',0);
            pslink.verifier.codegen.Coder.addDynamicProperty(uddObj,'isFullDataTypeRange','bool',false);
        end



        function addDynamicProperty(uddObj,propName,propType,defaultValue)%#ok<INUSL>

            if~isprop(uddObj,propName)
                prop=addprop(uddObj,propName);
                prop.Hidden=true;
                uddObj.(propName)=defaultValue;
            end
        end




        function embeddedObj=getUnderlyingType(embeddedObj)
            embeddedObj=pslink.verifier.codegen.Coder.getCoderType(embeddedObj);
            if isa(embeddedObj,'embedded.matrixtype')||isa(embeddedObj,'embedded.pointertype')
                embeddedObj=pslink.verifier.codegen.Coder.getUnderlyingType(embeddedObj.BaseType);
            end
        end



        function embeddedObj=getCoderType(embeddedObj)
            if isa(embeddedObj,'coder.types.Type')
                embeddedObj=embeddedObj.getEmbeddedType;
            end
        end

    end
end



