classdef CodeMetrics<rtw.codemetrics.C_CodeMetrics









































    properties(SetAccess=private,Hidden=true,Transient=true)
        BuildInfo={};
    end
    properties(SetAccess=private)
        BuildDir='';
    end
    methods
        function this=CodeMetrics(buildDir,varargin)
            this=this@rtw.codemetrics.C_CodeMetrics({},[],{},[],1);

            if ischar(buildDir)
                if~isfolder(buildDir)
                    error(message('RTW:utility:dirDoesNotExist',buildDir));
                end
                if isfile(fullfile(buildDir,'buildInfo.mat'))
                    load(fullfile(buildDir,'buildInfo.mat'),'buildInfo');
                else
                    error(message('Coder:reportGen:invalidBuildDir'));
                end
            else
                error(message('Coder:reportGen:invalidBuildDir'));
            end

            if~isempty(varargin)&&~isempty(varargin{1})
                hwcfg=varargin{1};
            else
                hwcfg=coder.HardwareImplementation;
            end
            if~isa(hwcfg,'coder.HardwareImplementation')
                error(message('Coder:reportGen:invalidHWImpl'));
            end


            if length(varargin)>1
                option=varargin{2};
                fileListOverride=this.parseOption(option);
            else
                fileListOverride={};
            end

            this.BuildDir=buildDir;
            this.BuildInfo=buildInfo;
            this.createCodeMetricsOption(hwcfg,1);
            this.setFileList(fileListOverride);
            this.calculateCodeMetrics();
        end
    end

    methods(Hidden=true)
        function size_struct=getHardwareSize(~,varargin)
            if nargin>1
                hwcfg=varargin{1};
            else
                hwcfg=coder.HardwareImplementation;
            end
            if hwcfg.ProdEqTarget

                size_struct.charNumBits=hwcfg.ProdBitPerChar;
                size_struct.shortNumBits=hwcfg.ProdBitPerShort;
                size_struct.intNumBits=hwcfg.ProdBitPerInt;
                size_struct.longNumBits=hwcfg.ProdBitPerLong;
                size_struct.floatNumBits=hwcfg.ProdBitPerFloat;
                size_struct.doubleNumBits=hwcfg.ProdBitPerDouble;
                size_struct.pointerNumBits=hwcfg.ProdBitPerPointer;
                size_struct.sizeTNumBits=hwcfg.ProdBitPerSizeT;
                size_struct.ptrDiffTNumBits=hwcfg.ProdBitPerPtrDiffT;
                size_struct.wordSize=hwcfg.ProdWordSize;
            else

                size_struct.charNumBits=hwcfg.TargetBitPerChar;
                size_struct.shortNumBits=hwcfg.TargetBitPerShort;
                size_struct.intNumBits=hwcfg.TargetBitPerInt;
                size_struct.longNumBits=hwcfg.TargetBitPerLong;
                size_struct.floatNumBits=hwcfg.TargetBitPerFloat;
                size_struct.doubleNumBits=hwcfg.TargetBitPerDouble;
                size_struct.pointerNumBits=hwcfg.TargetBitPerPointer;
                size_struct.sizeTNumBits=hwcfg.TargetBitPerSizeT;
                size_struct.ptrDiffTNumBits=hwcfg.TargetBitPerPtrDiffT;
                size_struct.wordSize=hwcfg.TargetWordSize;
            end
        end

        function out=getDataCopyDetailsFeature(~)
            out=false;
        end

        function out=getGlobalConstantsEstimationFeature(~)
            out=false;
        end

        function out=getToolchainDependentCodeMetricsFeature(~)
            out=true;
        end
        function out=getReportStructFieldDetailsInCodeMetrics(~)
            out=true;
        end
    end

    methods(Hidden=true,Access=protected)
        function calculateCodeMetrics(this)
            calculateCodeMetrics@rtw.codemetrics.C_CodeMetrics(this);



            mlRoot=matlabroot();
            funcs=this.FcnInfo;
            funcFiles=cellfun(@(f)f{1},{funcs.File},'UniformOutput',false);
            funcMask=~startsWith(funcFiles,mlRoot)&ismember(funcFiles,this.FileList);

            idxAdjust=cumsum(funcMask);
            removedIdx=find(~funcMask);
            for i=find(funcMask)
                funcs(i).Idx=idxAdjust(i);
                removedCalls=ismember(funcs(i).CalleeIdx,removedIdx);
                funcs(i).Callee(removedCalls)=[];
                calleeIdx=funcs(i).CalleeIdx;
                calleeIdx(removedCalls)=[];
                funcs(i).CalleeIdx=idxAdjust(calleeIdx);
            end

            this.FcnInfo=funcs(funcMask);
            this.RecursiveFcnIdx=idxAdjust(this.RecursiveFcnIdx);

            if~isempty(this.FcnInfo)
                this.FcnIdxMap=containers.Map({this.FcnInfo.Name},{this.FcnInfo.Idx});
            else
                this.FcnIdxMap=containers.Map();
            end
        end
    end

    methods(Access=private)
        function createCodeMetricsOption(this,hwcfg,UsePolySpace)
            cmOption=this.CodeMetricsOption;
            ProdEndianess=hwcfg.ProdEndianess;
            if strcmp(ProdEndianess,'BigEndian')
                cmOption.Target.Endianness='big';
            else
                cmOption.Target.Endianness='little';
            end
            size_struct=this.getHardwareSize(hwcfg);
            cmOption.Target.CharNumBits=size_struct.charNumBits;
            cmOption.Target.ShortNumBits=size_struct.shortNumBits;
            cmOption.Target.IntNumBits=size_struct.intNumBits;
            cmOption.Target.FloatNumBits=size_struct.floatNumBits;
            cmOption.Target.DoubleNumBits=size_struct.doubleNumBits;
            cmOption.Target.LongNumBits=size_struct.longNumBits;
            cmOption.Target.PointerNumBits=size_struct.pointerNumBits;

            cmOption.Preprocessor.Defines=...
            rtw.codemetrics.C_CodeMetrics.getMacrosForTarget(...
            size_struct.charNumBits,size_struct.shortNumBits,...
            size_struct.intNumBits,size_struct.longNumBits,size_struct.wordSize);

            if UsePolySpace
                BuildInfo_getDefines_D=reshape(strrep(this.BuildInfo.getDefines,'-D',''),length(strrep(this.BuildInfo.getDefines,'-D','')),1);
                cmOption.Preprocessor.Defines=[cmOption.Preprocessor.Defines;BuildInfo_getDefines_D];
            else
                cmOption.Preprocessor.Defines=...
                [cmOption.Preprocessor.Defines,strrep(this.BuildInfo.getDefines,'-D','')];
            end
            incDir=getIncludePaths(this.BuildInfo,true);
            for i=1:length(incDir)
                aPath=incDir{i};
                if~isempty(aPath)&&aPath(1)=='.'

                    aPath=this.getFileFullName(fullfile(this.BuildDir,aPath));
                    if~isempty(aPath)
                        incDir{i}=aPath;
                    end
                end
            end






            ml_incDir={fullfile(matlabroot,'extern','include'),...
            fullfile(matlabroot,'simulink','include'),...
            fullfile(matlabroot,'toolbox','shared','simtargets'),...
            fullfile(matlabroot,'toolbox','coder','simulinkcoder_core','ext_mode','host','common'),...
            fullfile(matlabroot,'rtw','c','src','ext_mode','common')};
            cmOption.Preprocessor.IncludeDirs=[incDir,ml_incDir];

            [key,val]=this.BuildInfo.findBuildArg('GENERATE_ERT_S_FUNCTION');
            if~isempty(key)&&strcmp(val,'1')
                cmOption.Preprocessor.Defines{end+1}='MATLAB_MEX_FILE';
            end
            this.setCodeMetricsOption(cmOption);
        end

        function setFileList(this,fileListOverride)
            if nargin<2||isempty(fileListOverride)
                fileList=this.getFileListFromBuildInfo(this.BuildInfo);
            else
                fileList=reshape(fileListOverride,1,numel(fileListOverride));
            end


            tmp=cellfun(@(x)isfile(x),fileList,'UniformOutput',true);
            fileList=fileList(tmp);
            this.setFile(fileList);
        end

        function fileListOverride=parseOption(this,option)
            myOption=struct('IsDebug',false,'GenDataCopy',false,'FileList',{{}},'targetisCPP',false);
            if~isstruct(option)
                error(message('RTW:report:CodeMetricsInvalidOption'));
            end
            fields=fieldnames(option);
            delta=~ismember(fields,fieldnames(myOption));
            if sum(delta)>0
                error(message('RTW:report:CodeMetricsInvalidOption'));
            end
            if isfield(option,'IsDebug')
                myOption.IsDebug=option.IsDebug;
            end
            if isfield(option,'GenDataCopy')
                myOption.GenDataCopy=option.GenDataCopy;
            end
            if isfield(option,'FileList')
                fileListOverride=option.FileList;
            else
                fileListOverride=myOption.FileList;
            end






            if isfield(option,'targetisCPP')
                this.targetisCPP=option.targetisCPP;
                this.setCodeMetricsOption([]);
            end
            this.bDebug=myOption.IsDebug;
            this.bGenDataCopy=myOption.GenDataCopy;
        end
    end

    methods(Static,Hidden)
        function fileList=getFileListFromBuildInfo(buildInfo)
            buildInfoHdrFile=buildInfo.getIncludeFiles(true,true);

            buildInfo.updateFilePathsAndExtensions;
            fileList=buildInfo.getSourceFiles(true,true);
            fileList=[fileList,buildInfoHdrFile];




            ignore_idx=[];
            for i=1:length(buildInfoHdrFile)
                [~,~,ext]=fileparts(buildInfoHdrFile{i});
                if strcmpi(ext,'.c')
                    ignore_idx(end+1)=i;%#ok
                end
            end
            ignore_file=buildInfoHdrFile(ignore_idx);
            fileList=setdiff(fileList,ignore_file);
        end
    end
end


