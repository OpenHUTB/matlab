




classdef DataRepositoryFacade<handle
    properties
BlockID
Results

RunLoggedVariablesInfo
    end

    methods(Static)
        function S=instrumentationDataMap(blkSID,coderReport,loggedVariablesData)
            persistent dataMap
            if isempty(dataMap)
                dataMap=coder.internal.mlfb.createBlockMap();
            end

            blockId=coder.internal.mlfb.idForBlock(blkSID);

            if nargin==3
                S.CoderReport=coderReport;
                S.LoggedVariablesData=loggedVariablesData;
                dataMap(blockId)=S;
            else
                if dataMap.isKey(blockId)
                    S=dataMap(blockId);
                else
                    S=[];
                end
            end
        end

        function res=isChecksumUptodate(mlfbChecksum,prevChecksum)
            res=false;


            if~strcmp(prevChecksum.chartChecksum,mlfbChecksum.chartChecksum)
                return;
            end


            mlChecksumMap=mlfbChecksum.matlabChecksum;
            prevMlChecksumMap=prevChecksum.matlabChecksum;
            if length(prevMlChecksumMap.keys)~=length(mlChecksumMap.keys)
                return;
            end
            mlkeys=mlChecksumMap.keys;
            for ii=1:length(mlkeys)
                mlkey=mlkeys{ii};
                if~prevMlChecksumMap.isKey(mlkey)
                    return;
                end
                if~all(prevMlChecksumMap(mlkey)==mlChecksumMap(mlkey))
                    return;
                end
            end

            res=true;
            return;
        end

        function mlfbCheckSum=computeCoderReportCheckSum(SID,coderReport)


            chartCheckSum=coder.internal.MLFcnBlock.Float2FixedManager.computeCheckSum(SID);


            mlScriptChkSumMap=containers.Map();
            scripts=coderReport.inference.Scripts([coderReport.inference.Scripts.IsUserVisible]);
            for ii=1:length(scripts)
                scriptInfo=scripts(ii);
                p=scriptInfo.ScriptPath;

                if~isempty(p)&&p(1)~='#'
                    mlScriptChkSumMap(p)=CGXE.Utils.md5(scriptInfo.ScriptText);
                end
            end

            mlfbCheckSum.chartChecksum=chartCheckSum;
            mlfbCheckSum.matlabChecksum=mlScriptChkSumMap;
        end
    end

    methods
        function this=DataRepositoryFacade(blockArg)
            this.BlockID=coder.internal.mlfb.idForBlock(blockArg);
            this.Results=containers.Map();
            this.RunLoggedVariablesInfo=containers.Map();
        end

        function removeRunTimeStampInfo(this,runName)
            if this.hasRunTimeStampInfo(runName)
                this.RunLoggedVariablesInfo.remove(runName);
            end
        end

        function addRunTimeStampInfo(this,runName,info)
            this.RunLoggedVariablesInfo(runName)=info;
        end

        function res=hasRunTimeStampInfo(this,runName)
            res=this.RunLoggedVariablesInfo.isKey(runName);
        end

        function info=getRunTimeStampInfo(this,runName)
            info=this.RunLoggedVariablesInfo(runName);
        end

        function res=isRunStale(this,runName,currChecksum)

            runMlfbChecksum=this.RunLoggedVariablesInfo(runName);
            res=~coder.internal.MLFcnBlock.DataRepositoryFacade.isChecksumUptodate(runMlfbChecksum,currChecksum);
        end

        function addResults(this,runName,~)
            this.Results(runName)=true;
        end

        function addRun(this,runName)
            this.Results(runName)=true;
        end

        function removeAllRuns(this)
            this.Results=containers.Map();
        end

        function removeRun(this,runName)
            if this.hasRunResult(runName)
                this.Results.remove(runName);
            end
        end


        function perMLFBResults=getResults(this,runName)
            repository=fxptds.FPTRepository.getInstance();
            dataset=repository.getDatasetForSource(this.BlockID.ModelName);
            runObj=dataset.getRun(runName);
            r=runObj.getResults;
            perMLFBResults=fxptds.MATLABVariableResult.empty();

            for j=1:length(r)
                currRecord=r(j);
                uniqueID=currRecord.getUniqueIdentifier;
                res_daobject=uniqueID.getObject;

                if isa(currRecord,'fxptds.MATLABVariableResult')&&...
                    strcmp(res_daobject.MATLABFunctionIdentifier.SID,this.BlockID.SID)

                    perMLFBResults(end+1)=currRecord;%#ok<AGROW>
                end
            end
        end

        function res=hasRunResult(this,runName)
            res=this.Results.isKey(runName);
        end

        function mappedResult=getMappedResult(this,varResult)
            varIdentifier=varResult.getUniqueIdentifier;
            functionIdentifier=varIdentifier.MATLABFunctionIdentifier;



            mappedResult.VarResult=varResult;


            mappedResult.FunctionName=functionIdentifier.FunctionName;
            if functionIdentifier.NumberOfInstances>1
                mappedResult.FunctionSpecializationId=functionIdentifier.InstanceCount;
            else
                mappedResult.FunctionSpecializationId=-1;
            end
            mappedResult.ScriptPath=functionIdentifier.ScriptPath;


            mappedResult.VarName=varIdentifier.VariableName;
            if varIdentifier.NumberOfInstances>1
                mappedResult.VarSpecializationId=varIdentifier.InstanceCount;
            else
                mappedResult.VarSpecializationId=-1;
            end


            mappedResult.MxInfoID=varIdentifier.MxInfoID;
            mappedResult.ChosenType=varResult.getProposedDT;

            if~isempty(strfind(mappedResult.ChosenType,'numerictype'))
                [~,mappedResult.ChosenType]=evalc(mappedResult.ChosenType);
            end

            mappedResult.SimMin=[];
            mappedResult.SimMax=[];

            simMin=varResult.getPropValue('SimMin');
            simMax=varResult.getPropValue('SimMax');
            if~isempty(simMin)
                mappedResult.SimMin=str2double(simMin);
            end
            if~isempty(simMax)
                mappedResult.SimMax=str2double(simMax);
            end
        end

        function mappedResults=getMappedResults(this,runName)
            mappedResults=[];

            if~this.hasRunResult(runName)
                return;
            end

            runResults=this.getResults(runName);
            for ii=1:numel(runResults)
                varResult=runResults(ii);
                mappedResult=this.getMappedResult(varResult);

                if isempty(mappedResults)
                    mappedResults=mappedResult;
                else
                    mappedResults(end+1)=mappedResult;
                end
            end
        end

        function[compilationReport,instrumentationReport,loggedVariablesData]=getReports(this)
            compilationReport=this.getCompilationReport();
            instrumentationReport=[];
            loggedVariablesData=[];

            S=this.instrumentationDataMap(this.BlockID);
            if~isempty(S)
                [instrumentationReport,loggedVariablesData]=this.getInstrumentationReport();
            end
        end
    end

    methods
        function[instrumentationReport,loggedVariablesData]=getInstrumentationReport(this)
            instrumentationReport=[];
            loggedVariablesData=[];
            S=this.instrumentationDataMap(this.BlockID);
            if~isempty(S)
                instrumentationReport=S.CoderReport;
                loggedVariablesData=S.LoggedVariablesData;

                if coder.internal.gui.debugmode
                    if~isempty(instrumentationReport)
                        [~,chkSum1]=fileparts(instrumentationReport.summary.htmldirectory);
                    else
                        chkSum1='';
                    end

                    compReport=this.getCompilationReport();
                    if~isempty(compReport)
                        [~,chkSum2]=fileparts(compReport.summary.htmldirectory);
                    else
                        chkSum2='';
                    end

                end
            end
        end

        function compilationReport=getCompilationReport(this)
            compilationReport=[];

            blk=this.BlockID.Block;
            emlChart=fxptds.getSFChartObject(blk);
            chartId=emlChart.Id;
            blockH=get_param(emlChart.Path,'handle');

            try

                ignoreErr=true;
                MATLABFunctionBlockSpecializationCheckSum=sf('SFunctionSpecialization',chartId,blockH,ignoreErr);
                [~,mainInfoName,~,~]=sfprivate('get_report_path',pwd,MATLABFunctionBlockSpecializationCheckSum,false);

                if~exist(mainInfoName,'file')



                    modeldir=fileparts(emlChart.Machine.FullFileName);
                    reportDir=fullfile(sfprivate('get_sf_proj',modeldir),...
                    'EMLReport');
                    mainInfoName=fullfile(reportDir,...
                    [MATLABFunctionBlockSpecializationCheckSum,'.mat']);
                end


                load(mainInfoName,'report');
                compilationReport=report;
            catch ex %#ok<NASGU>


                return;
            end
        end
    end

end

