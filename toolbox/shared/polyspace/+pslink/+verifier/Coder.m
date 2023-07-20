classdef Coder<handle




    properties(Hidden=true,SetAccess=protected,GetAccess=public)
slSystemName
slModelName
slModelFileName
slModelVersion
sysDirInfo
cgDirStatus
cgName
cgDir
isMdlRef
hasInternalError
drsInfo
fcnInfo
fileInfo
dlinkInfo
arInfo
codeInfo
needUnload
stubList
stubFile
isCheckOnly
mustWriteAllData
booleanTypes
inputFullRange
outputFullRange
paramFullRange
fcnToStub


SourceEncoding
    end

    methods(Access=public)




        function self=Coder(arg1,arg2)
            if nargin<1
                error('pslink:wrongNumberArg',DAStudio.message('polyspace:gui:pslink:wrongNumberArg','Coder'));
            end
            validateattributes(arg1,{'char'},{'row'},'Coder','arg1',1);

            codeGenFolder='';
            iSlSystemName='';
            iIsMdlRef=false;
            if strcmpi(arg1,'-codegenfolder')
                validateattributes(arg2,{'char'},{'row'},'Coder','arg2',2);
                codeGenFolder=arg2;
            else
                if nargin==2
                    validateattributes(arg2,{'logical','numeric'},{'scalar'},'Coder','arg2',2);
                    iIsMdlRef=logical(arg2);
                end
                iSlSystemName=arg1;
            end

            self.sysDirInfo=[];
            self.cgDirStatus=false;
            self.cgDir='';
            self.cgName='';
            self.isMdlRef=iIsMdlRef;
            self.hasInternalError=false;
            self.isCheckOnly=false;
            self.needUnload=false;

            if~isempty(iSlSystemName)
                try
                    modelName=strtok(iSlSystemName,'/');
                    if isempty(find_system(0,'Type','block_diagram','Name',modelName))
                        load_system(modelName);
                        self.needUnload=true;
                    end
                    self.slModelName=bdroot(iSlSystemName);
                    self.slModelFileName=get_param(self.slModelName,'FileName');
                    self.slModelVersion=get_param(self.slModelName,'ModelVersion');
                catch Me
                    error('pslink:invalidSystem',message('polyspace:gui:pslink:invalidSystem',regexprep(iSlSystemName,'\n',' ')).getString())
                end

                self.slSystemName=iSlSystemName;
            elseif~isempty(codeGenFolder)
                codegenID=pslink.verifier.codegen.Coder.getCodegenID(codeGenFolder);
                self.cgDir=codeGenFolder;
                self.slModelName=codegenID;
                self.slSystemName=codegenID;
                self.slModelVersion='';
            else


                assert(false,'Arguments must be a codegen folder or a Simulink system name');
            end

            self.drsInfo=pslink.verifier.Coder.createAllRangeInfoStruct();
            self.fcnInfo=pslink.verifier.Coder.createAllFcnInfoStruct();
            self.arInfo=pslink.verifier.Coder.createAllARInfoStruct();
            self.fileInfo=pslink.verifier.Coder.createFileInfoStruct();
            self.dlinkInfo=[];
            self.codeInfo=[];

            self.stubList={};
            self.stubFile={};

            self.SourceEncoding=matlab.internal.i18n.locale.default.Encoding;
        end




        function delete(self)
            if self.needUnload
                try
                    close_system(self.slModelName);
                catch Me %#ok<NASGU>

                end
            end
        end





        function arInfo=getAutosarInfo(self)
            arInfo=self.arInfo;
        end





        function drsInfo=getDataRangeInfo(self)
            drsInfo=self.drsInfo;
        end





        function fcnInfo=getFcnExecutionInfo(self)
            fcnInfo=self.fcnInfo;
        end





        function fileInfo=getFileInfo(self,unused)%#ok<INUSD>
            fileInfo=self.fileInfo;
        end





        function dlinkInfo=getLinkDataInfo(self)
            dlinkInfo=self.dlinkInfo;
        end




        function booleanTypes=getBooleanType(self)
            booleanTypes=self.booleanTypes;
        end




        function fcnToStub=getFcnToStub(self)
            fcnToStub=self.fcnToStub;
        end

    end

    methods(Abstract)

        extractAllInfo(self,opts)
        checkSum=getCheckSum(self)
    end

    methods(Static=true)



        function obj=createCoderObject(coderID,arg2,arg3)
            if nargin<2
                error('pslink:wrongNumberArg',DAStudio.message('polyspace:gui:pslink:wrongNumberArg','createCoderObject'));
            end
            if strcmpi(coderID,pslink.verifier.codegen.Coder.CODER_ID)
                validateattributes(arg2,{'char'},{'row'},'createCoderObject','codeGenFolder',2);
                codeGenFolder=arg2;
                obj=pslink.verifier.codegen.Coder(codeGenFolder);
            elseif strcmpi(coderID,pslink.verifier.ec.Coder.CODER_ID)
                if nargin<3
                    iIsMdlRef=false;
                else
                    validateattributes(arg3,{'logical','numeric'},{'scalar'},'createCoderObject','isMdlRef',2);
                    iIsMdlRef=logical(arg3);
                end
                validateattributes(arg2,{'char'},{'row'},'createCoderObject','slSystemName',2);
                iSlSystemName=arg2;

                obj=pslink.verifier.ec.Coder(iSlSystemName,iIsMdlRef);
            elseif strcmpi(coderID,pslink.verifier.tl.Coder.CODER_ID)
                validateattributes(arg2,{'char'},{'row'},'createCoderObject','slSystemName',2);
                iSlSystemName=arg2;
                obj=pslink.verifier.tl.Coder(iSlSystemName,false);
            elseif strcmpi(coderID,pslink.verifier.sfcn.Coder.CODER_ID)
                validateattributes(arg2,{'char'},{'row'},'createCoderObject','sfcnName',2);
                iSFcnName=arg2;
                if nargin<3
                    options=[];
                else
                    options=arg3;
                end
                obj=pslink.verifier.sfcn.Coder(iSFcnName,options);
            elseif strcmpi(coderID,pslink.verifier.slcc.Coder.CODER_ID)
                validateattributes(arg2,{'char'},{'row'},'createCoderObject','blockPath',2);
                iBlockPath=arg2;
                if nargin<3
                    options=[];
                else
                    options=arg3;
                end
                obj=pslink.verifier.slcc.Coder(iBlockPath,options);
            else
                obj=[];
            end
        end




        function allInfo=createAllRangeInfoStruct()
            allInfo=struct(...
            'input',struct([]),...
            'output',struct([]),...
            'param',struct([]),...
            'dsm',struct([]),...
            'data',struct([]),...
            'fcn',struct([]),...
            'busInfo',struct([])...
            );
        end




        function dataInfo=createDataRangeInfoStruct()
            dataInfo=struct(...
            'pos',[],...
            'expr','',...
            'min',[],...
            'max',[],...
            'lsb',[],...
            'offset',[],...
            'mode','init',...
            'emit',true,...
            'width',1,...
            'isPtr',false,...
            'isStruct',false,...
            'isArray',false,...
            'isExtraData',false,...
            'isFullDataTypeRange',false,...
            'field',[],...
            'udata',[],...
            'sourceFile',''...
            );
        end




        function fcnInfo=createFcnRangeInfoStruct()
            fcnInfo=struct(...
            'name','',...
            'sourceFile','',...
            'return',struct([]),...
            'arg',struct([]),...
            'emit',true...
            );
        end




        function codeInfo=createAllARInfoStruct()
            codeInfo.fcn=struct([]);
            codeInfo.ver='';
            codeInfo.dsm={};
            codeInfo.compName='';
            codeInfo.idMaxLength=32;
        end




        function fcnInfo=createARFcnInfoStruct()
            fcnInfo=pslink.verifier.Coder.createFcnRangeInfoStruct();
            fcnInfo.drsName='';
            fcnInfo.stubbed=false;
        end




        function dataInfo=createARFcnArgInfoStruct()
            dataInfo=pslink.verifier.Coder.createDataRangeInfoStruct();
            dataInfo.typeName='';
            dataInfo.direction='in';
            dataInfo.kind='';
        end




        function codeInfo=createAllFcnInfoStruct()
            codeInfo=struct(...
            'mustWriteAllData',false,...
            'init',struct([]),...
            'step',struct([]),...
            'term',struct([]),...
            'className',[],...
            'codeLanguage',''...
            );
        end




        function fcnInfo=createFcnInfoStruct()
            fcnInfo=struct(...
            'fcn',[],...
            'var',[],...
            'sTime',[]...
            );
        end




        function buildInfo=createFileInfoStruct()
            buildInfo=struct(...
            'source',[],...
            'include',[],...
            'define',[]...
            );
        end




        function dlinkInfo=createLinkDataInfoStruct()
            dlinkInfo=struct(...
            'name','',...
            'codename','',...
            'path','',...
            'sid',''...
            );
        end




        function ctmlinkInfo=createCodeToModelInfoStruct()
            ctmlinkInfo=struct(...
            'sid','',...
            'token','',...
            'file','',...
            'line','',...
            'beginCol','',...
            'endCol',''...
            );
        end

    end

end


