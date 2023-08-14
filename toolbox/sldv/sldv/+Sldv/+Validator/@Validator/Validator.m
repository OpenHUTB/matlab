



classdef Validator<handle
    properties
        sldvData;
        modelH;
        extractedModel;
        replacementModel;
        modelToValidate;
        objectiveToGoalMap;
        testComp;
        goalIdToObjectiveMap;
        runTestObj;
        testCompAnalysisInfo;
        simMode;
        isStandaloneValidator;
    end

    properties(Access=protected)
        mProfileLogger;
    end

    methods
        function obj=Validator(sldvdata,model,objectiveToGoalMap,testComp,goalIdToObjectiveMap,runTestObj)
            if nargin<3
                objectiveToGoalMap=[];
            end
            if nargin<4
                testComp=[];
            end
            if nargin<5
                goalIdToObjectiveMap=[];
            end
            if nargin<6
                runTestObj=[];
            end
            if ischar(model)
                obj.modelH=get_param(model,'handle');
            else
                obj.modelH=model;
            end
            obj.sldvData=sldvdata;
            obj.objectiveToGoalMap=objectiveToGoalMap;
            obj.testComp=testComp;
            obj.testCompAnalysisInfo=testComp.analysisInfo;
            obj.goalIdToObjectiveMap=goalIdToObjectiveMap;
            obj.runTestObj=runTestObj;
            obj.simMode=obj.testComp.simMode;
            obj.isStandaloneValidator=false;
            obj.mProfileLogger=testComp.getValidationProfileLogger();
        end

        function useParallelPool=initialize(obj,useParallelPool)
            if nargin<2
                useParallelPool=false;
            end

            [status,errMsgObj]=sldvprivate('globalWsCheckAccess',obj.modelH);

            if~status
                error(errMsgObj.Identifier,getString(errMsgObj));
            end

            obj.runTestObj=Sldv.RunTestCase(mfilename);
            sldvdata=obj.sldvData;
            if strcmp(sldvdata.AnalysisInformation.Options.Mode,'TestGeneration')
                sldvdata.TestCases=[];
                runOpts=obj.getRunOpts(obj.modelH,sldvdata);
            elseif(strcmp(sldvdata.AnalysisInformation.Options.Mode,'DesignErrorDetection'))
                sldvdata.CounterExamples=[];
                runOpts=obj.getRunOpts(obj.modelH,sldvdata);
            else
                assert(strcmp(sldvdata.AnalysisInformation.Options.Mode,'PropertyProving'));
                sldvdata.CounterExamples=[];
                runOpts=obj.getRunOpts(obj.modelH);
            end

            runOpts.useParallel=useParallelPool;





            if isprop(obj,'blockParameterStruct')
                obj.runTestObj.initialize(obj.modelH,sldvdata,runOpts,obj.blockParameterStruct);
            else
                obj.runTestObj.initialize(obj.modelH,sldvdata,runOpts);
            end
        end

        function restore(obj)
            obj.runTestObj.restore();
        end

        function checkTestCase(obj,tc,goalToTestcaseMap)
            goals=tc.goals;
            stopped=false;
            while~stopped
                for goal=goals(:)'
                    if obj.goalIdToObjectiveMap.isKey(goal.getGoalMapId)&&...
                        ~strcmp(goal.type,'AVT_GOAL_PATH_OBJECTIVE')
                        if~goalToTestcaseMap.isKey(goal.getGoalMapId)
                            atStep=tc.satisfiedDepth(goal);
                            if atStep~=0
                                if strcmp(goal.status,'GOAL_UNDECIDED_STUB')
                                    continue;
                                elseif(isequal(goal.type,'AVT_GOAL_DESRANGE')||...
                                    isequal(goal.type,'AVT_GOAL_ARRBOUNDS'))&&...
                                    goalToTestcaseMap.isKey(goal.getGoalMapId)
                                    continue;
                                end
                                goalToTestcaseMap(goal.getGoalMapId)=tc;
                            end
                        end
                    end
                end
                stopped=~sldvprivate('sldv_datamodel_isa',tc.up,'TestCase');
                tc=tc.up;
                if~stopped
                    goals=tc.goals;
                end
            end
        end

        function noTestcaseGoals=updateNoTestCaseStatus(obj)
            noTestcaseGoals=[];
            goalToTestcaseMap=containers.Map('KeyType','double','ValueType','any');
            testComp=obj.testComp;
            testCases=sldvprivate('sldv_datamodel_get_testcases',testComp);

            for tc=testCases'
                if sldvprivate('sldv_datamodel_isempty',tc.down)




                    obj.checkTestCase(tc,goalToTestcaseMap);
                end
            end

            goalIds=obj.goalIdToObjectiveMap.keys;
            for i=1:obj.goalIdToObjectiveMap.Count
                goal=testComp.getGoal(goalIds{i});
                if goal.testIndex==0&&(strcmp(goal.status,'GOAL_SATISFIABLE_NEEDS_SIMULATION')||...
                    strcmp(goal.status,'GOAL_FALSIFIABLE_NEEDS_SIMULATION')||...
                    strcmp(goal.status,'GOAL_UNDECIDED_STUB_NEEDS_SIMULATION'))
                    force=false;

                    if strcmp(goal.status,'GOAL_UNDECIDED_STUB_NEEDS_SIMULATION')
                        currentStatus='GOAL_UNDECIDED_STUB';
                    else
                        currentStatus=goal.status;
                    end

                    goal.testIndex=-1;
                    aTcIdx=0;
                    testComp.updateValidatedGoals(goalIds{i},string(currentStatus),force,aTcIdx);
                    noTestcaseGoals=[noTestcaseGoals,goalIds{i}];%#ok<AGROW>
                end
            end
        end

        [isCovered,count,noCoverage,isUnvalidated]=validateObjective(obj,goal,covData,varargin);
        out=ignoreObjectiveForValidation(obj,objIdx);
    end

    methods(Abstract)
        validate(obj,testCasestoValidate,useParallel)
    end
end
