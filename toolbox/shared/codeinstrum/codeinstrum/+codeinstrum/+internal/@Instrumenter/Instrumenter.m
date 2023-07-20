classdef(Hidden=true)Instrumenter<handle










    properties(Hidden,Constant)
        EXTERN_C_BLOCK_START_STR=sprintf('#ifdef __cplusplus\nextern "C" {\n#endif')
        EXTERN_C_BLOCK_END_STR=sprintf('#ifdef __cplusplus\n}\n#endif')
        EXTERN_C_DEF_STR=sprintf('#ifdef __cplusplus\nextern "C"\n#endif')
        EXTERN_C_DECL_STR=sprintf('#ifdef __cplusplus\nextern "C"\n#else\nextern\n#endif')
    end

    properties(Access=public)


        outInstrDir='';



        instrPrefix='i_';

        code2ModelRecords=[];


        booleanTypes={};


        codeCovProbeComponentRegistry=[];

    end
    properties(Access=public,Dependent=true)

        dbFilePath;

        anchorDir;

        moduleName;

        Options;


        outDir;

        InstrVarRadix;
        InstrFcnRadix;
        InstrFcnSuffix;


        serializeFilesWithoutCoverageInDB;

        isPerFileTRData;

SrcFileName

        structuralChecksum;

        traceabilityData;

        UniqueID;
    end

    properties(Access=public,Hidden=true)
        runCBeautifierOnInstrumentedFiles=false;
    end

    properties(SetAccess=protected,GetAccess=public,Hidden=true)
        InstrumImpl;
    end

    methods

        function set.InstrVarRadix(this,aValue)
            validateattributes(aValue,{'char'},{'row'},'','InstrVarRadix');
            this.InstrumImpl.InstrVarRadix=aValue;
        end


        function InstrVarRadix=get.InstrVarRadix(this)
            InstrVarRadix=this.InstrumImpl.InstrVarRadix;
        end


        function set.InstrFcnRadix(this,aValue)
            validateattributes(aValue,{'char'},{'row'},'','InstrFcnRadix');
            this.InstrumImpl.Options.InstrFcnRadix=aValue;
        end


        function InstrFcnRadix=get.InstrFcnRadix(this)
            InstrFcnRadix=this.InstrumImpl.Options.InstrFcnRadix;
        end


        function set.InstrFcnSuffix(this,aValue)
            validateattributes(aValue,{'char'},{'row'},'','InstrFcnSuffix');
            this.InstrumImpl.Options.InstrFcnSuffix=aValue;
        end


        function InstrFcnSuffix=get.InstrFcnSuffix(this)
            InstrFcnSuffix=this.InstrumImpl.Options.InstrFcnSuffix;
        end


        function set.serializeFilesWithoutCoverageInDB(this,aValue)
            this.InstrumImpl.serializeFilesWithoutCoverageInDB=aValue;
        end


        function serializeFilesWithoutCoverageInDB=get.serializeFilesWithoutCoverageInDB(this)
            serializeFilesWithoutCoverageInDB=this.InstrumImpl.serializeFilesWithoutCoverageInDB;
        end


        function SrcFileName=get.SrcFileName(this)
            SrcFileName=this.InstrumImpl.SrcFileName;
        end


        function set.SrcFileName(this,aValue)
            assert(isempty(this.InstrumImpl.SrcFileName));
            assert(this.isPerFileTRData==true);
            this.InstrumImpl.SrcFileName=aValue;
        end


        function set.dbFilePath(this,aValue)
            this.InstrumImpl.dbFilePath=aValue;
        end


        function dbFilePath=get.dbFilePath(this)
            dbFilePath=this.InstrumImpl.dbFilePath;
        end


        function traceabilityData=get.traceabilityData(this)
            traceabilityData=this.InstrumImpl.traceabilityData;
        end


        function set.anchorDir(this,aValue)
            this.InstrumImpl.anchorDir=aValue;
        end


        function anchorDir=get.anchorDir(this)
            anchorDir=this.InstrumImpl.anchorDir;
        end


        function set.moduleName(this,aValue)
            this.InstrumImpl.moduleName=aValue;
        end


        function moduleName=get.moduleName(this)
            moduleName=this.InstrumImpl.moduleName;
        end


        function set.outDir(this,aValue)
            this.InstrumImpl.outDir=aValue;
        end


        function outDir=get.outDir(this)
            outDir=this.InstrumImpl.outDir;
        end


        function set.Options(this,aValue)
            this.InstrumImpl.Options=aValue;
        end


        function Options=get.Options(this)
            Options=this.InstrumImpl.Options;
        end


        function set.isPerFileTRData(this,aValue)
            this.InstrumImpl.isPerFileTRData=aValue;
        end


        function isPerFileTRData=get.isPerFileTRData(this)
            isPerFileTRData=this.InstrumImpl.isPerFileTRData;
        end


        function set.structuralChecksum(this,aValue)
            this.InstrumImpl.structuralChecksum=aValue;
        end


        function structuralChecksum=get.structuralChecksum(this)
            structuralChecksum=this.InstrumImpl.structuralChecksum;
        end

        function set.UniqueID(this,aValue)
            this.InstrumImpl.UniqueID=aValue;
        end


        function UniqueID=get.UniqueID(this)
            UniqueID=this.InstrumImpl.UniqueID;
        end
    end

    methods(Access=public)



        function this=Instrumenter(varargin)
            dbFilePath='';
            isPerFileTRData=false;
            Options=internal.cxxfe.instrum.InstrumOptions();
            for ii=1:numel(varargin)
                arg=varargin{ii};
                if ischar(arg)&&isempty(dbFilePath)
                    dbFilePath=arg;
                elseif isa(arg,'internal.cxxfe.instrum.InstrumOptions')
                    Options=arg;
                elseif isa(arg,'logical')
                    isPerFileTRData=arg;
                else
                    assert(false);
                end
            end

            this.InstrumImpl=internal.cxxfe.instrum.Instrumenter(dbFilePath,Options,pwd,pwd);
            this.isPerFileTRData=isPerFileTRData;
        end




        function res=getDbFilePath(this,escapePath)
            res=this.InstrumImpl.dbFilePath;
            if nargin==2&&escapePath
                res=strrep(res,'\','\\');
            end
        end




        prepareModuleInstrumentation(this,incrementalBuild)





        finalizeModuleInstrumentation(this,funBeforeTrDelete)




        function setSourceKind(this,sourceKind)
            this.InstrumImpl.setSourceKind(sourceKind);
        end




        function setVerbosity(this,verbosityLevel)
            this.InstrumImpl.setVerbosity(verbosityLevel);
        end




        extraOpts=instrumentFile(this,srcFile,frontEndOptions,extraOpts)




        function[maxCovId,hTableSize]=getCovTableSize(this)
            sizeInfo=this.getInstrumDataSizeInfo();
            maxCovId=double(sizeInfo.maxCovId);
            hTableSize=double(sizeInfo.instrumHitsTableSize);
        end




        out=getInstrumDataInfo(this,force)




        sizeInfo=getInstrumDataSizeInfo(this,instrDataInfo)




        function outStr=getInstrumDataDeclarations(this)

            instrDataInfo=this.getInstrumDataInfo();

            outStr='';
            if instrDataInfo.hasExtraFlag
                outStr=sprintf('%s\n\n',instrDataInfo.vExtraFlag.decl);
            end

            sizeInfo=this.getInstrumDataSizeInfo(instrDataInfo);
            sz=sizeInfo.instrumHitsTableSize;
            if sz==0
                sz=1;
            end

            outStr=sprintf('%s%s\n\n%s\n\n%s\n\n%s\n\n%s\n',...
            outStr,...
            instrDataInfo.vHitsSize.decl,...
            instrDataInfo.vHitsPtr.decl,...
            instrDataInfo.vAbsTol.decl,...
            instrDataInfo.vRelTol.decl,...
            instrDataInfo.vHits.decl(sz)...
            );
        end




        function outStr=getInstrumDataDefinitions(this)
            outStr=this.generateInstrumUtilsSrc(false);
        end
        function setFinalDBName(this)
            this.InstrumImpl.setFinalDBName();
        end




        outStr=generateInstrumUtilsSrc(this,generateHeader)




        function res=getDbBytesAsString(this)
            assert(isempty(this.InstrumImpl.traceabilityData));


            codeTr=codeinstrum.internal.TraceabilityData(this.dbFilePath);
            jsonStr=codeTr.serializeToJSON();



            [dirPath,base]=fileparts(this.dbFilePath);
            tmpFile=fullfile(dirPath,[base,'.json']);
            [tmpfid,errMsg]=fopen(tmpFile,'w','n','utf8');
            if tmpfid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForWritingError',tmpFile,errMsg);
            end
            fprintf(tmpfid,'%s',jsonStr);
            fclose(tmpfid);


            zipFile=[tempname(fileparts(this.dbFilePath)),'.zip'];
            zip(zipFile,tmpFile);
            delete(tmpFile);

            [zipfid,errMsg]=fopen(zipFile,'rb');
            if zipfid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForReadingError',zipFile,errMsg);
            end
            arr=fread(zipfid,Inf,'*uint8');
            fclose(zipfid);
            delete(zipFile);

            res=codeinstrum.internal.Utils.formatBytesAsString(arr);
        end
    end

    methods(Static)



        function version=getActualVersion()
            version='X.Y.Z';
        end




        function toolPath=getToolPath()
            toolPath=fullfile(matlabroot,'bin',computer('arch'));
        end




        function out=getToolInstallationFile()
            out='libmwcxxfe_instrum';
            if ispc()
                out=[out,'.dll'];
            elseif ismac()
                out=[out,'.dylib'];
            else
                out=[out,'.so'];
            end
        end




        function UniqueID=computeUniqueID(filename,crc)
            crc=join(string(dec2hex(crc)),"");
            [~,stemFileName,~]=fileparts(filename);
            UniqueID=[char(stemFileName),'_',char(crc)];
        end




        function this=instance(dbFilePath,varargin)

            this=codeinstrum.internal.Instrumenter(dbFilePath);
            if nargin>1
                this.isPerFileTRData=varargin{1};
            end

            if exist(dbFilePath,'file')
                try
                    this.InstrumImpl.open();
                    this.Options=internal.cxxfe.instrum.InstrumOptions.load(this.InstrumImpl.traceabilityData);
                    this.structuralChecksum=this.InstrumImpl.traceabilityData.computeChecksum(true);
                    this.InstrumImpl.close();
                catch ME %#ok<NASGU>
                    this=[];
                end
            else
                this=[];
            end
        end
    end
end




