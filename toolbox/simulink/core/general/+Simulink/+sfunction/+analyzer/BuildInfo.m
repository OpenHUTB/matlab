












































classdef BuildInfo
    properties
SfcnFile
    end

    properties(Dependent,SetAccess=private)
SfcnName
SrcType
    end
    properties
SrcPaths
ExtraSrcFileList
ObjFileList
IncPaths
LibFileList
LibPaths
PreProcDefList
    end

    properties(SetAccess=private,Hidden=true)
BuildXmlFile
    end

    properties(Hidden=true)
targetDir
isDebug
    end

    methods(Access=private)
        function re=IsValidSfcnSource(obj,input)
            re=false;
            if exist(input,'file')==2
                [~,~,ext]=fileparts(input);
                if isequal(ext,'.c')||isequal(ext,'.cpp')
                    re=true;
                end
            end
        end

        function IsValidFile(obj,option,value)
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput',option);
            assert(iscellstr(value)||isstring(value),'Simulink:SFunctions:ComplianceCheckInvalidFileInput',errorMsg);
        end
    end

    methods

        function obj=BuildInfo(SfcnFile,varargin)
            SfcnFile=convertStringsToChars(SfcnFile);
            p=inputParser;

            defaultBuildXmlFile='';
            checkBuildXmlFile=@(x)exist(x,'file')==2;

            errorMsgSfcnFile=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidSfcnSource');
            errorIdSfcnFile='Simulink:SFunctions:ComplianceCheckInvalidSfcnSource';
            checkSfcnFile=@(x)assert(obj.IsValidSfcnSource(x),errorIdSfcnFile,errorMsgSfcnFile);

            errorId='Simulink:SFunctions:ComplianceCheckInvalidFileInput';

            defaultLibFileList={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','LibFileList');
            checkLibFileList=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultExtraSrcFileList={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','ExtraSrcFileList');
            checkExtraSrcFileList=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultObjFileList={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','ObjFileList');
            checkObjFileList=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultIncPaths={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','IncPaths');
            checkIncPaths=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultLibPaths={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','LibPaths');
            checkLibPaths=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultSrcPaths={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','SrcPaths');
            checkSrcPaths=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);

            defaultPreProcDefList={};
            errorMsg=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidFileInput','PreProcDefList');
            checkPreProcDefList=@(x)assert(iscellstr(x)||isstring(x),errorId,errorMsg);


            addRequired(p,'SfcnFile',checkSfcnFile);
            addParameter(p,'BuildXmlFile',defaultBuildXmlFile,checkBuildXmlFile);
            addParameter(p,'LibFileList',defaultLibFileList,checkLibFileList);
            addParameter(p,'ExtraSrcFileList',defaultExtraSrcFileList,checkExtraSrcFileList);
            addParameter(p,'ObjFileList',defaultObjFileList,checkObjFileList);
            addParameter(p,'IncPaths',defaultIncPaths,checkIncPaths);
            addParameter(p,'LibPaths',defaultLibPaths,checkLibPaths);
            addParameter(p,'SrcPaths',defaultSrcPaths,checkSrcPaths);
            addParameter(p,'PreProcDefList',defaultPreProcDefList,checkPreProcDefList);


            parse(p,SfcnFile,varargin{:});




            obj.BuildXmlFile=p.Results.BuildXmlFile;
            if exist(obj.BuildXmlFile,'file')==2
                try
                    [sfunctionFile,libFileList,srcFileList,objFileList,...
                    addIncPaths,addLibPaths,addSrcPaths,...
                    preProcDefList,~,~]=...
                    Simulink.sfunction.analyzer.internal.parseAutoBuildXml(obj.BuildXmlFile);
                catch ex
                    ex=MException('','buildXmlFile is invalid.');
                    throw(ex);
                end
                obj.SfcnFile=sfunctionFile;
                obj.LibFileList=libFileList;
                obj.ExtraSrcFileList=srcFileList;
                obj.ObjFileList=objFileList;
                obj.IncPaths=addIncPaths;
                obj.LibPaths=addLibPaths;
                obj.SrcPaths=addSrcPaths;
                obj.PreProcDefList=preProcDefList;
            else

                obj.BuildXmlFile='';
                obj.SfcnFile=convertStringsToChars(p.Results.SfcnFile);
                obj.ExtraSrcFileList=convertStringsToChars(p.Results.ExtraSrcFileList);
                obj.LibFileList=convertStringsToChars(p.Results.LibFileList);
                obj.ObjFileList=convertStringsToChars(p.Results.ObjFileList);
                obj.IncPaths=convertStringsToChars(p.Results.IncPaths);
                obj.LibPaths=convertStringsToChars(p.Results.LibPaths);
                obj.SrcPaths=convertStringsToChars(p.Results.SrcPaths);
                obj.PreProcDefList=convertStringsToChars(p.Results.PreProcDefList);
            end
            obj.targetDir='';
            obj.isDebug='yes';
        end


        function obj=set.SfcnFile(obj,value)
            errorMsgSfcnFile=DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidSfcnSource');
            assert(obj.IsValidSfcnSource(value),'Simulink:SFunctions:ComplianceCheckInvalidSfcnSource',errorMsgSfcnFile);
            obj.SfcnFile=value;

        end

        function SrcType=get.SrcType(obj)
            [~,~,ext]=fileparts(obj.SfcnFile);
            switch ext
            case '.c'
                SrcType='C';
            case{'.cpp','.cc'}
                SrcType='CPP';
            otherwise
                SrcType='';
            end
        end

        function SfcnName=get.SfcnName(obj)
            [~,SfcnName,~]=fileparts(obj.SfcnFile);
        end

        function obj=set.ExtraSrcFileList(obj,value)
            obj.IsValidFile('ExtraSrcFileList',value);
            obj.ExtraSrcFileList=value;
        end

        function obj=set.LibFileList(obj,value)
            obj.IsValidFile('LibFileList',value);
            obj.LibFileList=value;
        end

        function obj=set.ObjFileList(obj,value)
            obj.IsValidFile('ObjFileList',value);
            obj.ObjFileList=value;
        end

        function obj=set.IncPaths(obj,value)
            obj.IsValidFile('IncPaths',value);
            obj.IncPaths=value;
        end

        function obj=set.LibPaths(obj,value)
            obj.IsValidFile('LibPaths',value);
            obj.LibPaths=value;
        end

        function obj=set.SrcPaths(obj,value)
            obj.IsValidFile('SrcPaths',value);
            obj.SrcPaths=value;
        end

        function obj=set.PreProcDefList(obj,value)
            obj.IsValidFile('PreProcDefList',value);
            obj.PreProcDefList=value;
        end

    end

end

