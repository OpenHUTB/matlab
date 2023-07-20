classdef SLCustomCodeCov<handle






    properties

dbPath


covId2ScriptName


fileName2Info


libName2Info


libPath2Info


sfcnCov


modelRefNameMap


excludedModels
    end

    methods



        function this=SLCustomCodeCov()
            this.reset();
        end




        function reset(this)
            this.dbPath='';
            this.covId2ScriptName=containers.Map('KeyType','double','ValueType','char');
            this.fileName2Info=containers.Map('KeyType','char','ValueType','any');
            this.libName2Info=containers.Map('KeyType','char','ValueType','any');
            this.libPath2Info=containers.Map('KeyType','char','ValueType','any');
            this.modelRefNameMap=containers.Map('KeyType','char','ValueType','char');
            this.excludedModels=containers.Map('KeyType','char','ValueType','any');
            this.sfcnCov=cvi.SFunctionCov();
        end





        function res=toInfoStruct(this)

            sfcnNames=this.sfcnCov.sfcnName2Info.keys();
            libNames=this.libName2Info.keys();
            numSFcn=numel(sfcnNames);
            numLib=numel(libNames);

            res.Details=repmat(cvi.SLCustomCodeCov.newInfoStruct(),[1,numSFcn+numLib]);

            for ii=1:numSFcn
                sfcnInfo=this.sfcnCov.sfcnName2Info(sfcnNames{ii});
                res.Details(ii)=sfcnInfo;
            end

            for ii=1:numLib
                res.Details(ii+numSFcn)=this.libName2Info(libNames{ii});
            end
        end




        function createDbFolder(this)
            if~isempty(this.dbPath)&&~isfolder(this.dbPath)
                try
                    this.dbPath=rtwprivate('rtw_create_directory_path',this.dbPath,'');
                catch Mex
                    throwAsCaller(Mex);
                end
            end
        end





        function setupDbPath(this,coveng)
            modelName=get_param(coveng.topModelH,'Name');
            try
                buildDir=RTW.getBuildDir(modelName);
            catch


                fGenObj=Simulink.fileGenControl('getConfig');
                buildDir.CacheFolder=fGenObj.CacheFolder;
                buildDir.ModelRefRelativeSimDir=fullfile('slprj','sim',modelName);
            end
            this.dbPath=fullfile(buildDir.CacheFolder,buildDir.ModelRefRelativeSimDir,'slcc_cov');



        end




        function status=extractModelRefMap(this,coveng)


            status=false;


            if isempty(coveng.topModelH)
                return
            end

            this.modelRefNameMap=containers.Map('KeyType','char','ValueType','char');

            if cvi.SLCustomCodeCov.isMdlRefCovEnabled(coveng.topModelH)
                topModelName=get_param(coveng.topModelH,'Name');



                [normalModelRefs,normalModelRefBlocks]=...
                cv.ModelRefData.getMdlReferences(topModelName,true,false);
                normalModelRefs=unique(normalModelRefs);
                normalModelRefBlocks=unique(normalModelRefBlocks);



                excludedMdlRef=get_param(topModelName,'CovModelRefExcluded');
                if~isempty(excludedMdlRef)&&strcmpi(get_param(topModelName,'CovModelRefEnable'),'filtered')
                    modelRefInfo=SlCov.Utils.extractExcludedModelInfo(excludedMdlRef);
                    normalModelRefs=setdiff(normalModelRefs,modelRefInfo.normal);
                    for ii=1:numel(modelRefInfo.normal)
                        this.excludedModels(modelRefInfo.normal{ii})=true;
                    end
                end

                if~cvi.SLCustomCodeCov.isMdlCovEnabled(topModelName)&&isempty(normalModelRefs)


                    return
                end



                for kk=1:numel(normalModelRefBlocks)
                    mdlRefBlk=normalModelRefBlocks{kk};
                    if(strcmpi(get_param(mdlRefBlk,'BlockType'),'ModelReference'))
                        mdlRefName=get_param(mdlRefBlk,'ModelName');
                        if ismember(mdlRefName,normalModelRefs)
                            mdlRefBlkInstanceName=get_param(mdlRefBlk,'NormalModeModelName');

                            if~isempty(mdlRefBlkInstanceName)
                                this.modelRefNameMap(mdlRefBlkInstanceName)=mdlRefName;
                            end
                        end
                    end
                end

            end

            status=true;
        end
    end

    methods(Static)

        addResults(coveng,modelCovId)
        updateResults(coveng,forPause)
        setup(coveng)
        setupModel(coveng,modelH)
        ccInfo=init(modelH)
        pause(coveng,modelH)
        newTestIds=fastRestart(coveng,modelH)
        term(coveng,modelH)
        isOk=checkDataConsistency(currData,cumData)
        ccInfo=registerInstance(topModelH,id)
    end

    methods(Static,Hidden)



        function status=isMdlCovEnabled(modelH)
            status=strcmpi(get_param(modelH,'RecordCoverage'),'on');
        end




        function status=isMdlRefCovEnabled(modelH)
            status=~strcmpi(get_param(modelH,'CovModelRefEnable'),'off');
        end





        function s=newInfoStruct()

            s=struct(...
            'name',[],...
            'isSF',0,...
            'instances',[],...
            'numDec',0,...
            'numDecOutcomes',[],...
            'numCond',0,...
            'truthTablesForMCDC',[],...
            'exprsForMCDC',[],...
            'numCyclo',0,...
            'dbFile',[],...
            'trFileMap',containers.Map('KeyType','char','ValueType','char'),...
            'codeTrMap',containers.Map('KeyType','char','ValueType','any'),...
            'codeTr',[],...
            'numRelOp',0,...
            'numRelOpOutcomes',[],...
            'condsForMCDC',[],...
            'libPath',''...
            );
        end





        function s=newInstanceResultsInfoStruct(name)

            s=struct(...
            'name',name,...
            'modelName','',...
            'instanceIdx',[],...
            'resultIdx',[]...
            );
        end




        function s=newInstanceInfoStruct(name)

            s=struct(...
            'name',name,...
            'dbFile','',...
            'dbTrFile','',...
            'modelName','',...
            'libName','',...
            'isFiltered',false...
            );
        end




        function[numCyclo,numDec,numDecOutcomes,numCond,truthTable,exprsForMCDC,numRelOp,numRelOpOutcomes,condsForMCDC]=...
            extractCovMetricInfoFromCodeTr(codeTr,fileIdx)

            if nargin<2

                obj=codeTr.Root;
            else
                files=codeTr.getFilesInResults();
                assert(fileIdx<=numel(files),'File index is out of range');
                obj=files(fileIdx);
            end

            decCovPts=codeTr.getDecisionPoints(obj);
            numDec=numel(decCovPts);
            numDecOutcomes=zeros(numDec,1);
            for ii=1:numel(decCovPts)
                numDecOutcomes(ii)=decCovPts(ii).outcomes.Size();
            end

            condCovPts=codeTr.getConditionPoints(obj);
            numCond=numel(condCovPts);

            numCyclo=codeTr.getCycloCplx(obj);
            numCyclo=numCyclo(1);

            relOpCovPts=codeTr.getRelationalBoundaryPoints(obj);
            numRelOp=numel(relOpCovPts);
            numRelOpOutcomes=zeros(numRelOp,1);
            for ii=1:numel(relOpCovPts)
                numRelOpOutcomes(ii)=relOpCovPts(ii).outcomes.Size();
            end

            mcdcCovPts=codeTr.getMCDCPoints(obj);
            condsForMCDC=cell(numel(mcdcCovPts),1);
            truthTable=cell(numel(mcdcCovPts),1);
            exprsForMCDC={mcdcCovPts.expr};
            for ii=1:numel(mcdcCovPts)
                decCovPt=mcdcCovPts(ii).parentDecision;
                [~,condsForMCDC{ii}]=ismember(decCovPt.subConditions.toArray(),condCovPts);
                tt=mcdcCovPts(ii).truthTable.toArray();
                numCols=mcdcCovPts(ii).outcomes.Size()+1;
                truthTable{ii}=reshape(tt,[mcdcCovPts(ii).numCombinations,numCols]);
            end
        end




        function dbFilePath=unzipDb(dbFileByte,dbPath,fcnName,newName)

            dbFilePath='';

            try
                zipFileName=fullfile(dbPath,[fcnName,'.zip']);
                fid=fopen(zipFileName,'wb');
                fwrite(fid,dbFileByte,'*uint8');
                fclose(fid);
                files=unzip(zipFileName,dbPath);
                dbFilePath=files{1};
                if nargin==4&&~isempty(newName)
                    [dbP,~,dbE]=fileparts(dbFilePath);
                    newFilePath=fullfile(dbP,[newName,dbE]);
                    movefile(dbFilePath,newFilePath,'f');
                    dbFilePath=newFilePath;
                end
            catch

            end

            try
                if~isempty(dir(zipFileName))
                    delete(zipFileName);
                end
            catch

            end
        end


        function obj=createInstance(coveng)

            obj=cvi.SLCustomCodeCov();



            obj.setupDbPath(coveng);
        end


        function cvt=getCvTest(coveng,modelCovId,testKind)

            if nargin<3
                testKind='.currentTest';
            end


            if nargin<2||isempty(modelCovId)
                modelCovId=0;
                if~isempty(coveng.lastReportingModelH)
                    modelCovId=get_param(coveng.lastReportingModelH,'CoverageId');
                end
            end


            testId=0;
            if modelCovId>0
                testId=cv('get',modelCovId,testKind);
            end
            if testId==0
                cvt=[];
            else
                cvt=cvtest(testId);
            end
        end
    end
end


