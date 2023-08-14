




classdef EmitterDb<sldv.code.internal.EmitterDb

    methods




        function this=EmitterDb(varargin)
            this.extractAnalysisInfo(varargin{:});
        end





        function covStruct=getCodeCoverageInfo(this,slHandle,moduleName)

            covStruct=struct([]);

            key='';
            if nargin==3
                key=moduleName;
                if isempty(key)
                    return
                end
            end

            if isempty(key)
                if nargin<2
                    return
                end
                modelName=getAnalyzedModelName(slHandle);
                key=SlCov.coder.EmbeddedCoder.buildModuleName(modelName,char(this.SimulationMode));
            end

            if this.CoverageInfos.isKey(key)
                covStruct=this.CoverageInfos(key);
            else
                buildDirInfo=sldv.code.xil.CodeAnalyzer.getModuleBuilDirInfo(key);
                trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(key,buildDirInfo);
                if~isfile(trDataFile)
                    return
                end
                traceabilityData=sldv.code.xil.internal.TraceabilityDb(trDataFile);
                traceabilityData.computeShortestUniquePaths();
                traceabilityData.close();

                covStruct=struct('codeTr',traceabilityData,...
                'moduleName',{moduleName},...
                'topModelName',{getAnalyzedModelName(slHandle)});
                this.CoverageInfos(key)=covStruct;
            end

            function modelName=getAnalyzedModelName(slHandle)
                if~isempty(this.OriginalModel)
                    slHandle=this.OriginalModel;
                end
                if ischar(slHandle)
                    modelName=slHandle;
                else
                    modelName=get_param(slHandle,'Name');
                end
            end
        end





        function moduleH=getModuleHandle(~,~,moduleName)
            moduleH=-1;
            [modelName,~,isSharedUtilities]=SlCov.coder.EmbeddedCoder.parseModuleName(moduleName);
            if isSharedUtilities
                modelName='sldvlib';
            end
            if~bdIsLoaded(modelName)
                try
                    load_system(modelName);
                catch
                    return
                end
            end
            moduleH=get_param(modelName,'Handle');
        end




        function sharedInfo=getSharedCodeCoverageInfo(this)

            sharedInfo=[];


            keys=this.CoverageInfos.keys();
            values=this.CoverageInfos.values(keys);


            numInfo=4;
            chkInfo=cell(0,numInfo);
            insertIdx=1;
            for ii=1:numel(keys)

                [~,~,isSharedUtilities]=SlCov.coder.EmbeddedCoder.parseModuleName(keys{ii});
                if isSharedUtilities
                    continue
                end

                codeTr=values{ii}.codeTr;
                files=codeTr.getFilesInResults();


                chkInfo=[chkInfo;cell(numel(files),numInfo)];%#ok<AGROW>


                for jj=1:numel(files)
                    file=files(jj);
                    chk=sprintf('%02X',file.structuralChecksum.toArray());
                    covIdRange=codeTr.getCovIdRange(file);
                    chkInfo(insertIdx,:)={...
                    chk,...
                    keys{ii},...
                    double(covIdRange(1)),...
                    double(covIdRange(2))...
                    };
                    insertIdx=insertIdx+1;
                end
            end


            [~,ia,ic]=unique(chkInfo(:,1),'stable');
            for ii=1:numel(ia)

                idx=find(ic==ia(ii));
                if numel(idx)<2
                    continue
                end


                sharedInfo=[sharedInfo;chkInfo(idx,:)];%#ok<AGROW>
            end
        end




        function codeKind=getCodeKind(~)
            codeKind='xil';
        end
    end

    methods(Access=protected)




        function out=makeCodeLink(this,covStruct,fileId,firstLine)
            out=[];
            if isfield(covStruct,'moduleName')&&isfield(covStruct,'topModelName')
                out=struct(...
                'topModelName',covStruct.topModelName,...
                'moduleName',covStruct.moduleName,...
                'fileId',fileId,...
                'line',firstLine,...
                'codeKind',this.getCodeKind());
            end
        end




        function extractAnalysisInfo(this,varargin)
            if nargin<2
                simMode='SIL';
            else
                simMode=varargin{1};
            end
            if nargin<3
                modelName='';
            else
                modelName=varargin{2};
            end

            this.CodeDb=sldv.code.xil.internal.InstanceDb();

            this.CoverageInfos=containers.Map('KeyType','char','ValueType','any');

            this.AnalysisMode=sldv.code.CodeAnalyzer.AnalysisInstance;

            testComp=Sldv.Token.get.getTestComponent();
            if~isempty(testComp)
                opts=testComp.activeSettings;

                analysisInfo=testComp.analysisInfo;
                analyzedModelName=get_param(analysisInfo.analyzedModelH,'Name');

                model=analysisInfo.designModelH;
                if model~=analysisInfo.analyzedModelH
                    this.OriginalModel=get_param(model,'Name');
                    analyzedModelName=this.OriginalModel;
                end
                if testComp.isModelRefSIL()
                    simMode='ModelRefSIL';
                else
                    simMode='SIL';
                end
            elseif~isempty(modelName)
                model=get_param(modelName,'handle');
                analyzedModelName=modelName;
                opts=sldvoptions(modelName);
                this.OriginalModel=modelName;
            else
                assert(false,'Cannot get model name');
            end

            this.SimulationMode=simMode;


            sldv.code.xil.modelAnalysis(...
            analyzedModelName,opts,...
            'testComponent',testComp,...
            'simulationMode',simMode);

            if simMode=="SIL"
                loader=sldv.code.xil.internal.CodeInfoLoader();
            else
                loader=sldv.code.xil.internal.CodeInfoLoaderModelRef();
            end
            this.CodeDb=loader.loadCodeDb(model,opts);
        end




















        function[analysis,info]=getEntryInfoFromHandle(this,slHandle)

            analysis=[];
            info=[];

            if this.CodeDb.hasInfo()

                if~isempty(this.OriginalModel)
                    slHandle=this.OriginalModel;
                end


                if ischar(slHandle)
                    modelName=slHandle;
                    slHandle=get_param(modelName,'Handle');
                else
                    modelName=get_param(slHandle,'Name');
                end


                codeAnalyzer=sldv.code.xil.internal.getCurrentCodeAnalyzer();
                if~isempty(codeAnalyzer)&&~isempty(codeAnalyzer.AtsHarnessInfo)&&...
                    isstruct(codeAnalyzer.AtsHarnessInfo)

                    isATS=true;
                    harnessInfo=codeAnalyzer.AtsHarnessInfo;
                else
                    [isATS,harnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(modelName);
                end
                if isATS
                    modelName=harnessInfo.model;
                    if~bdIsLoaded(modelName)
                        load_system(modelName);
                        unloadModel=onCleanup(@()bdclose(modelName));
                    end
                    slHandle=get_param(modelName,'handle');
                end


                if isempty(codeAnalyzer)||~strcmp(codeAnalyzer.ModelName,modelName)
                    codeAnalyzer=sldv.code.xil.CodeAnalyzer();
                    codeAnalyzer.ModelName=modelName;
                    codeAnalyzer.SimulationMode=this.SimulationMode;
                    codeAnalyzer.AtsHarnessInfo=harnessInfo;
                end
                codeDesc=codeAnalyzer.getCodeDescriptor();
                if isempty(codeDesc)||isempty(codeDesc.codeInfo)
                    return
                end

                instInfo=sldv.code.xil.CodeInstanceInfo();
                instInfo.setInstanceIdFromHandle(slHandle);
                instInfo.setFromCodeDescriptor(codeDesc);
                if isATS
                    codeDbEntryName=harnessInfo.ownerFullPath;
                else
                    if~isempty(this.OriginalModel)
                        modelName=get_param(bdroot(slHandle),'Name');
                        instInfo.updateModelName(modelName,this.OriginalModel);
                    end
                    codeDbEntryName=modelName;
                end

                [analysis,info]=this.CodeDb.getAnalysisInfo(codeDbEntryName,...
                instInfo,this.AnalysisMode,this.SimulationMode);

            end
        end
    end
end


