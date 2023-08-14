classdef PLCConfigInfo<plccore.common.Object



    properties(Constant)
        UDTAOIListFcnName_SUFFIX='udt_aoi_list'
        AOIBlockListFcnName_SUFFIX='aoi_block_list'
        MdlDataStructName_SUFFIX='value'
        MdlDataMATFileName_SUFFIX='value.mat'
        L5XCGFileName_SUFFIX='gen'
    end

    properties(Access=protected)
FileDir
FileName
OpenModel
GenerateAOIModel
TopAOIName
PreserveAOIEnable
KeepLibModel
SupportUnknownInstruction
UseCtx
Ctx
Debug
SkipArgOrderCheck
AllowDisabledAOIRoutine
SkipConformanceChecks
DisableCallbacks
SampleTime
    end

    methods
        function obj=PLCConfigInfo(file_dir,file_name)
            obj.Kind='PLCConfigInfo';
            if nargin==2
                obj.FileDir=file_dir;
                obj.FileName=file_name;
            else
                obj.FileDir=[];
                obj.FileName=[];
            end
            obj.OpenModel=false;
            obj.GenerateAOIModel=false;
            obj.PreserveAOIEnable=false;
            obj.TopAOIName=[];
            obj.KeepLibModel=false;
            obj.SupportUnknownInstruction=false;
            obj.UseCtx=false;
            obj.Ctx=[];
            obj.Debug=false;
            obj.SkipArgOrderCheck=false;
            obj.AllowDisabledAOIRoutine=false;
            obj.SkipConformanceChecks=false;
            obj.DisableCallbacks=false;
            obj.SampleTime=[];
        end

        function ret=fileDir(obj)
            assert(~isempty(obj.FileDir));
            ret=obj.FileDir;
        end

        function ret=fileName(obj)
            assert(~isempty(obj.FileName));
            ret=obj.FileName;
        end

        function ret=filePath(obj)
            ret=fullfile(obj.fileDir,obj.fileName);
        end

        function ret=baseFileName(obj)
            file_name=obj.fileName;
            pos=strfind(file_name,'.');
            assert(~isempty(pos));
            ret=file_name(1:pos(1)-1);
        end

        function ret=L5XProgName(obj)
            file_name=obj.fileName;
            pos=strfind(file_name,'.');
            assert(~isempty(pos));
            prog_name=sprintf('%s_%s%s',file_name(1:pos(1)-1),'prog',...
            file_name(pos(1):end));
            ret=prog_name;
        end

        function ret=L5XModelName(obj)
            if obj.generateAOIModel
                ret=sprintf('%s_runner',obj.topAOIName);
            else
                ret=obj.baseFileName;
            end
            obj.checkModelNameLength(ret);
        end

        function ret=L5XModuleModelName(obj)
            mdl_name=obj.L5XModelName;
            ret=sprintf('%s_lib',mdl_name);
            obj.checkModelNameLength(ret);
        end

        function ret=L5XBusDefineFileName(obj)
            busfile_name=sprintf('%s_bus.m',obj.L5XModelName);
            ret=busfile_name;
        end

        function ret=L5XBusClearFileName(obj)
            busfile_name=sprintf('%s_bus_clear.m',obj.L5XModelName);
            ret=busfile_name;
        end

        function parse(obj,file_path,args)
            if~endsWith(lower(file_path),'l5x')
                file_path=sprintf('%s.L5X',file_path);
            end

            if(exist(file_path,'file')~=2)
                plccore.common.plcThrowError(...
                'plccoder:plccore:LadderFileNotFound',...
                plccore.util.Msg(file_path));
            end

            [file_dir,fname_main,fname_ext]=fileparts(file_path);
            if isempty(file_dir)
                file_dir=pwd;
            end
            obj.FileName=[fname_main,fname_ext];
            obj.FileDir=file_dir;

            obj.parseArgs(args);
        end

        function ret=UDTAOIListFcnName(obj)
            ret=sprintf('%s_%s',obj.L5XModelName,obj.UDTAOIListFcnName_SUFFIX);
            obj.checkFunctionNameLength(ret);
        end

        function ret=AOIBlockListFcnName(obj)
            ret=sprintf('%s_%s',obj.L5XModelName,obj.AOIBlockListFcnName_SUFFIX);
            obj.checkFunctionNameLength(ret);
        end

        function ret=UDTAOIListFileName(obj)
            ret=sprintf('%s.m',obj.UDTAOIListFcnName);
        end

        function ret=AOIBlockListFileName(obj)
            ret=sprintf('%s.m',obj.AOIBlockListFcnName);
        end

        function ret=MdlDataStructName(obj)
            ret=sprintf('%s_%s',obj.L5XModelName,obj.MdlDataStructName_SUFFIX);
            obj.checkStructNameLength(ret);
        end

        function ret=MdlDataMATFileName(obj)
            ret=sprintf('%s_%s',obj.L5XModelName,obj.MdlDataMATFileName_SUFFIX);
        end

        function ret=L5XCGFileName(obj)
            ret=sprintf('%s_%s.L5X',obj.baseFileName,obj.L5XCGFileName_SUFFIX);
        end
    end

    methods
        function ret=openModel(obj)
            ret=obj.OpenModel;
        end

        function ret=keepLibModel(obj)
            ret=obj.KeepLibModel;
        end

        function ret=generateAOIModel(obj)
            ret=obj.GenerateAOIModel;
        end

        function ret=topAOIName(obj)
            ret=obj.TopAOIName;
        end

        function ret=preserveAOIEnable(obj)
            ret=obj.PreserveAOIEnable;
        end

        function ret=supportUnknownInstruction(obj)
            ret=obj.SupportUnknownInstruction;
        end

        function ret=disableCallbacks(obj)
            ret=obj.DisableCallbacks;
        end

        function ret=sampleTime(obj)
            ret=obj.SampleTime;
        end


        function ret=useCtx(obj)
            ret=obj.UseCtx;
        end

        function ret=ctx(obj)
            ret=obj.Ctx;
        end

        function ret=debug(obj)
            ret=obj.Debug;
        end

        function ret=skipArgOrderCheck(obj)
            ret=obj.SkipArgOrderCheck;
        end

        function ret=allowDisabledAOIRoutine(obj)
            ret=obj.AllowDisabledAOIRoutine;
        end

        function ret=skipConformanceChecks(obj)
            ret=obj.SkipConformanceChecks;
        end
    end

    methods(Access=private)
        function ret=validateString(obj,x)%#ok<INUSL>
            ret=ischar(x)||isstring(x);
        end

        function parseArgs(obj,args)
            if isempty(args)
                return;
            end

            p=inputParser;
            p.addParameter('OpenModel','off',@obj.validateString);
            p.addParameter('TopAOI',[],@obj.validateString);
            p.addParameter('PreserveAOIEnable','off',@obj.validateString);
            p.addParameter('KeepLibModel','off',@obj.validateString);
            p.addParameter('SupportUnknownInstruction','off',@obj.validateString);
            p.addParameter('UseCtx','',@obj.validateString);
            p.addParameter('Debug','off',@obj.validateString);
            p.addParameter('SkipArgOrderCheck','off',@obj.validateString);
            p.addParameter('AllowDisabledAOIRoutine','off',@obj.validateString);
            p.addParameter('SkipConformanceChecks','off',@obj.validateString);
            p.addParameter('Callbacks','on',@obj.validateString);
            p.addParameter('SampleTime',[]);

            p.parse(args{:})
            r=p.Results;
            if strcmpi(r.OpenModel,'on')
                obj.OpenModel=true;
            end

            if~isempty(r.TopAOI)
                obj.GenerateAOIModel=true;
                obj.TopAOIName=r.TopAOI;
            end

            if strcmpi(r.PreserveAOIEnable,'on')
                obj.PreserveAOIEnable=true;
            end

            if strcmpi(r.KeepLibModel,'on')
                obj.KeepLibModel=true;
            end

            if strcmpi(r.SupportUnknownInstruction,'on')
                obj.SupportUnknownInstruction=true;
            end

            if~isempty(r.UseCtx)
                obj.UseCtx=true;
                obj.loadCtx(r.UseCtx)
            end

            if strcmpi(r.Debug,'on')
                obj.Debug=true;
            end

            if strcmpi(r.SkipArgOrderCheck,'on')
                obj.SkipArgOrderCheck=true;
            end

            if strcmpi(r.AllowDisabledAOIRoutine,'on')
                obj.AllowDisabledAOIRoutine=true;
            end

            if strcmpi(r.SkipConformanceChecks,'on')
                obj.SkipConformanceChecks=true;
            end

            if strcmpi(r.Callbacks,'off')
                obj.DisableCallbacks=true;
            end

            if~isempty(r.Callbacks)
                obj.SampleTime=r.SampleTime;
            end

        end

        function loadCtx(obj,ctx_mat_name)
            assert(exist(ctx_mat_name,'file')==2,'mat file not found');
            load(ctx_mat_name,'ctx');
            assert(isa(ctx,'plccore.common.Context'));
            obj.Ctx=ctx;
        end

        function checkModelNameLength(obj,name)%#ok<INUSL>
            if length(name)>=namelengthmax
                plccore.common.plcThrowError(...
                'plccoder:plccore:ModelNameExceedLimit',...
                name);
            end
        end

        function checkFunctionNameLength(obj,name)%#ok<INUSL>
            if length(name)>=namelengthmax
                plccore.common.plcThrowError(...
                'plccoder:plccore:FunctionNameExceedLimit',...
                name);
            end
        end

        function checkStructNameLength(obj,name)%#ok<INUSL>
            if length(name)>=namelengthmax
                plccore.common.plcThrowError(...
                'plccoder:plccore:StructNameExceedLimit',...
                name);
            end
        end
    end
end


