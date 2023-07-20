



classdef TestcaseValidator<Sldv.Validator.Validator
    properties(Hidden=true)
        tcIdx;
        noopValidatedTcIdx;
        tcObjectiveIndices;
        FutureIdMapForTestcases;


        covContextGuard=[];
    end
    methods
        function obj=TestcaseValidator(sldvData,model,objectiveToGoalMap,testcomp,goalIdtoObjectiveMap,runTestObj)
            if nargin<5
                goalIdtoObjectiveMap=[];
            end
            if nargin<6
                runTestObj=[];
            end
            obj@Sldv.Validator.Validator(sldvData,model,objectiveToGoalMap,testcomp,goalIdtoObjectiveMap,runTestObj);

            if~ischar(model)
                model=get_param(model,'Name');
            end

            obj.covContextGuard=SlCov.ContextGuard(model);

            obj.initSimulationData;
        end

        function initSimulationData(obj)
            obj.tcIdx=[];
            obj.noopValidatedTcIdx=[];
            obj.tcObjectiveIndices=[];
            obj.FutureIdMapForTestcases=[];
        end

        function validatedStatus=updateStatus(obj,objectiveWithStatus,currentStatus)
            validatedStatus=obj.updateStatusForCoverageObjective(objectiveWithStatus,currentStatus);
        end

        function clearSimulationData(obj)
            obj.initSimulationData;
        end

        function delete(obj)

            delete(obj.covContextGuard);
        end

        [validatedTestCases,futureData,noopValidatedTcIdx]=validateIncremental(obj,testCases);

    end

    methods(Static)

        function runOpts=getRunOpts(modelH,sldvData,varargin)
            if nargin>2


                enableCoverage=~varargin{1};
            else
                enableCoverage=true;
            end
            sldvOpt=[];
            isExtractedMdl=false;

            if(nargin==2)||(nargin==3)
                sldvOpt=sldvData.AnalysisInformation.Options;
                isExtractedMdl=isfield(sldvData.ModelInformation,'ExtractedModel');
            end

            runOpts=sldvruntestopts;
            if enableCoverage
                runOpts.coverageEnabled=true;
                runOpts.coverageSetting=sldvprivate('create_cvtest',modelH,sldvOpt,isExtractedMdl);
            end
            runOpts.fastRestart=1;
        end

    end
end

