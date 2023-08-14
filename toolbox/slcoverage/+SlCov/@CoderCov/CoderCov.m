



classdef CoderCov<handle

    properties
        isModel=true
        isCoverageOn=false;
        modelCvtest=[]
        coveng=[]
    end

    methods(Static)

        function cvd=run(varargin)
            coveng.scriptDataMap=[];
            ci=SlCov.CoderCov.createInstance(coveng);
            ci.isCoverageOn=true;
            ci.start;
            ci.createCvTest;
            isMexInDesignPath=false;
            isEntryPointCompiled=true;
            tbExecCfg=coder.internal.TestBenchExecConfig(isMexInDesignPath,isEntryPointCompiled);
            coder.internal.runTest(tbExecCfg,varargin{:});
            if isempty(ci.modelCvtest)
                cvd=[];
            else
                cvd=ci.getResult;
            end
            ci.term;
            ci.isCoverageOn=false;
        end

        function obj=handleInstance(coveng)
            persistent uniqueInstance
            if nargin<1
                coveng=[];
            end

            if~isempty(coveng)
                obj=SlCov.CoderCov(coveng);
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end


        function obj=createInstance(coveng)
            obj=SlCov.CoderCov.handleInstance(coveng);
        end

        function obj=getInstance
            obj=SlCov.CoderCov.handleInstance();
        end

        function reset()
            ci=SlCov.CoderCov.getInstance;
            ci.isModel=true;
            ci.isCoverageOn=false;
        end

        function[scriptName,modelcovId]=getScriptName(scriptId)
            modelcovId=cv('get',scriptId,'.modelcov');
            scriptName=SlCov.CoverageAPI.getModelcovName(modelcovId);
        end


        function cvScriptId=scriptInit(path)
            ci=SlCov.CoderCov.getInstance;
            cvScriptId=0;
            if~ci.isCoverageOn||isempty(path)
                return;
            end
            path=fullfile(path);
            data=[];
            if~isempty(ci.coveng.scriptDataMap)
                data=ci.coveng.scriptDataMap({ci.coveng.scriptDataMap.scriptPath}==string(path));
            end
            if isempty(data)
                [data,modelcovId]=ci.init(path);
                ci.setCvTest(path,modelcovId);
                ci.addMapData(data);
            end
            cvScriptId=data.cvScriptId;
        end

        function cvScriptId=scriptStart(path)
            cvScriptId=0;
            ci=SlCov.CoderCov.getInstance;
            if~ci.isInstrumented
                return;
            end
            path=fullfile(path);
            idx=find({ci.coveng.scriptDataMap.scriptPath}==string(path));
            if~ci.coveng.scriptDataMap(idx).isAllocated
                ci.allocate(idx);
            end
            cvScriptId=ci.coveng.scriptDataMap(idx).cvScriptId;

        end

        function cvScriptId=scriptUpdateCvId(path)
            ci=SlCov.CoderCov.getInstance;
            data=ci.coveng.scriptDataMap({ci.coveng.scriptDataMap.scriptPath}==string(path));
            cvScriptId=data.cvScriptId;
        end

        function scriptExit(scriptId)
            ci=SlCov.CoderCov.getInstance;
            if~ci.isInstrumented
                return;
            end

            [scriptName,modelcovId]=SlCov.CoderCov.getScriptName(scriptId);
            fidx=find({ci.coveng.scriptDataMap.scriptName}==string(scriptName));
            if~isempty(fidx)
                ci.coveng.scriptDataMap(fidx)=[];
                if~ci.isModel
                    cv('ModelcovClear',modelcovId);
                end
            end
        end

        report(fileName,path)
    end

    methods
        function ci=CoderCov(coveng)
            ci.coveng=coveng;
        end

        function modelInit(ci,cvtestId)

            ci.start;
            ci.isModel=true;
            ci.isCoverageOn=true;
            if cvtestId~=0
                ci.modelCvtest=cvtest(cvtestId);
            end
        end

        function data=allocate(ci,idx)
            data=ci.coveng.scriptDataMap(idx);
            modelcovId=cv('get',data.cvScriptId,'.modelcov');

            cv('compareCheckSumForScript',modelcovId,data.oldRootId);
            testId=cv('get',modelcovId,'.activeTest');
            cvi.TopModelCov.setTestObjective(modelcovId,testId);
            cv('allocateModelCoverageData',modelcovId);

            if(data.oldRootId~=0)
                oldCvScriptId=cv('get',cv('get',cv('get',modelcovId,'.activeRoot'),'.topSlsf'),'.treeNode.child');

                if oldCvScriptId~=data.cvScriptId
                    ci.coveng.scriptDataMap(idx).cvScriptId=oldCvScriptId;
                end
            end
            ci.coveng.scriptDataMap(idx).isAllocated=true;
        end


        function modelcovIds=modelStart(ci)
            modelcovIds=[];
            if~ci.isInstrumented
                return;
            end
            for idx=1:numel(ci.coveng.scriptDataMap)
                data=ci.coveng.scriptDataMap(idx);
                modelcovId=cv('get',data.cvScriptId,'.modelcov');
                modelcovIds=[modelcovIds,modelcovId];
            end
        end

        function modelTerm(ci)
            ci.isModel=false;
            ci.isCoverageOn=false;


            covrtEnableCoverageLogging(false);
            covrtUseCV(false);
        end


        function res=isInstrumented(this)
            res=this.isCoverageOn&&...
            ~isempty(this.coveng.scriptDataMap);
        end


        function start(~)

            covrtEnableCoverageLogging(true);
            covrtUseCV(true);
        end

        function term(this)
            for idx=1:numel(this.coveng.scriptDataMap)
                data=this.coveng.scriptDataMap(idx);
                modelcovId=cv('get',data.cvScriptId,'.modelcov');
                cv('ModelcovTerm',modelcovId);
                cv('ModelcovClear',modelcovId);
            end

            covrtEnableCoverageLogging(false);
            covrtUseCV(false);
        end

        function cvdg=getResult(this)

            if isempty(this.coveng.scriptDataMap)
                cvdg=[];
                return;
            end
            if numel(this.coveng.scriptDataMap)>1
                cvdg=cv.cvdatagroup;
                for idx=1:numel(this.coveng.scriptDataMap)
                    data=this.coveng.scriptDataMap(idx);
                    modelcovId=cv('get',data.cvScriptId,'.modelcov');
                    testId=cv('get',modelcovId,'.activeTest');
                    cvd=cvdata(testId);
                    cvdg.add(cvd);
                end
            else
                data=this.scriptMap(1);
                cvdg=cvdata(data.cvtest.id);
            end
        end

        function createCvTest(this)
            testId=cvtest.create(0);
            this.modelCvtest=cvtest(testId);
            this.modelCvtest.settings.decision=1;
        end

        function cvt=setCvTest(this,scriptName,modelcovId)
            if isempty(this.modelCvtest)
                return;
            end
            testId=cvtest.create(modelcovId);
            cvt=clone(this.modelCvtest,cvtest(testId));
            info=dir(scriptName);
            cv('set',testId,'.lastModifiedDate',info.date);
            cv('set',testId,'.modelcov',modelcovId);




            metricNamesToTurnOff={'designverifier','overflowsaturation','relationalop'};
            for idx=1:numel(metricNamesToTurnOff)
                cmn=metricNamesToTurnOff{idx};
                cvt.setMetric(cmn,0);
            end

            cv('set',modelcovId,'.currentTest',0);
            activate(cvt,modelcovId);
        end

        function addMapData(this,data)
            if isempty(this.coveng.scriptDataMap)
                this.coveng.scriptDataMap=data;
            else
                this.coveng.scriptDataMap(end+1)=data;
            end
        end


        function removeMapData(this,scriptName)
            this.coveng.scriptDataMap.remove(scriptName);
        end

        [data,modelcovId]=init(this,path)
    end
end
