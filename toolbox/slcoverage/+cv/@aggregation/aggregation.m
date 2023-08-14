



classdef aggregation<cv.cvdatagroup
    properties(GetAccess=public)
    end
    properties(GetAccess=public,Hidden=true)
    end
    properties(Access=private)
        allData=[]
        results=[]
        reqInfo=[]
        useCvdataSum=true;
    end
    properties(GetAccess=public,SetAccess=public,Dependent=true,Hidden=true)
    end
    methods(Hidden)
        function res=isTraceOn(~)
            res=strcmpi(cv('Feature','Trace'),'on');
        end
    end
    methods

        function this=aggregation()
            this.allData=[];
            this.reqInfo=[];
            this.useCvdataSum=strcmpi(cv('Feature','aggregate with cvdata sum'),'on');
        end

        function addData(this,cvd,assoc)
            if nargin<3
                assoc='';
            end
            td=struct('cvd',{cvd},'assoc',{assoc});

            if~isempty(this.allData)
                this.allData(end+1)=td;
            else
                this.allData=td;
            end
        end

        cvdsum=getSumWithAddSubsys(this)

        function sum(this,param)
            if~isfield(param,'subsystemUnits')
                param.subsystemUnits={};
            end


            if~isfield(param,'mode')
                param.mode=0;
            end

            this.results=containers.Map('KeyType','double','ValueType','any');
            this.sumVariantModels(this.allData,param);
            this.rollUpSubsystems(this.allData,param);
            this.createResultsCvdatagroup;
        end

        rollUpSubsystems(this,modelData,param)

        sumVariantModels(this,modelData,param)


        function createResultsCvdatagroup(this)
            values=this.results.values;
            for idx=1:numel(values)
                v=values{idx};
                setAnalyzedModel(v.cvd,v.analyzedModel);
                name=SlCov.CoverageAPI.mangleModelcovName(v.analyzedModel,SlCov.CovMode.Normal,v.cvd.dbVersion);
                this.m_data(name)=v.cvd;
            end
        end


        function cvdsum=getSum(this)






            try
                cvdsum=cvdata.empty;
                numData=numel(this.allData);

                if this.useCvdataSum&&(numData>=2)&&...
                    all(arrayfun(@(td)isempty(td.assoc),this.allData))

                    this.allData(1).cvd.traceOn=true;
                    cvdsum=sum([this.allData.cvd]);
                else
                    for idx=1:numData
                        data=this.allData(idx).cvd;
                        assoc=this.allData(idx).assoc;

                        data.traceOn=true;

                        if isempty(cvdsum)
                            cvdsum=data;
                        else
                            if~isempty(assoc)
                                tmpCvdsum=cvdsum.addSubsystem(assoc,data);


                                if~isempty(tmpCvdsum)
                                    cvdsum=tmpCvdsum;
                                end
                            else
                                cvdsum=cvdsum+data;
                            end

                        end
                    end
                end



                if~isempty(cvdsum)&&~isempty(this.reqInfo)
                    cvdsum.processAgregatedInfo;
                    this.buildReqInfoSimulationStruct(cvdsum);
                    cvdsum.reqTestMapInfo=this.prepReqInfoForSave();
                end
            catch MEx
                rethrow(MEx);
            end
        end


        function setRequirementsMapping(this,reqInfo)
            this.reqInfo=[];

            if isfield(reqInfo,'Requirement')&&~isempty(reqInfo.Requirement)
                this.reqInfo=reqInfo;
            end
        end
    end
    methods(Hidden)




        function buildReqInfoSimulationStruct(this,cvdsum)




            this.reqInfo.Simulation=struct('RunId',{},'TestIdx',{},'URL',{},'Label',{});
            for i=1:length(this.reqInfo.Test)
                this.reqInfo.Test(i).SimulationInd=[];
            end

            ati=cvdsum.aggregatedTestInfo;
            for i=1:numel(ati)
                runInfo=ati(i).testRunInfo;
                testInds=this.testId2ReqInfoTestIdx(runInfo.testId);
                if~isempty(testInds)
                    runId=runInfo.runId;
                    url="matlab:stm.internal.util.highlightTestResult('"+runId+"');";
                    label=cvdsum.getTraceLabel(i);

                    simItem=struct('RunId',runId,'TestIdx',testInds,'URL',url.char,'Label',label);
                    this.reqInfo.Simulation(end+1)=simItem;
                    simIdx=length(this.reqInfo.Simulation);

                    for t=1:numel(testInds)
                        tIdx=testInds(t);
                        this.reqInfo.Test(tIdx).SimulationInd(end+1)=simIdx;
                    end
                end
            end
        end

        function testIdx=testId2ReqInfoTestIdx(this,testUUID)

            testIdx=[];
            if~isempty(testUUID)&&this.reqInfo.testUuid2IdxMap.isKey(testUUID)
                testIdx=this.reqInfo.testUuid2IdxMap(testUUID);
            end
        end

        reqInfoOut=prepReqInfoForSave(this);


    end
    methods(Static)
        [cutCvd,extractCvd]=extractAndCutVariantSubsystems(inCvdata);

        function map=setResult(map,ccvd)
            chks=ccvd.checksum;
            chksK=chks.u1+chks.u2+chks.u3+chks.u4;
            tvalue.cvd=ccvd;
            tvalue.analyzedModel=ccvd.modelinfo.analyzedModel;
            map(chksK)=tvalue;
        end

        function map=addToResult(map,ccvd)
            chks=ccvd.checksum;
            chksK=chks.u1+chks.u2+chks.u3+chks.u4;
            tvalue=[];
            if map.isKey(chksK)
                tvalue=map(chksK);
                tvalue.cvd=tvalue.cvd+ccvd;
                if isempty(tvalue.analyzedModel)
                    tvalue.analyzedModel=ccvd.modelinfo.analyzedModel;
                end
            else
                tvalue.cvd=ccvd;
                tvalue.analyzedModel=ccvd.modelinfo.analyzedModel;
            end
            map(chksK)=tvalue;
        end

    end
end
