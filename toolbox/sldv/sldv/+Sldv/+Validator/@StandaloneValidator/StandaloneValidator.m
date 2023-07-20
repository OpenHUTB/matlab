classdef StandaloneValidator<handle







    properties(Access=private)
        mModelH double
        mSldvData struct
        msldvDataTestCases struct
mTestComp
        mObjectiveToGoalMap containers.Map
        mGoalIDtoObjectiveMap containers.Map
        mComponentChecksum struct
        mCustomCodeChecksum struct
        mtestCasestoValidate struct
        mtestCaseIds double
        mUseParallel logical
    end


    methods(Access=public)
        function obj=StandaloneValidator(modelH,sldvData,testComp,useParallel)
            obj.mSldvData=sldvData;

            switch obj.mSldvData.AnalysisInformation.Options.Mode
            case 'PropertyProving'
                obj.msldvDataTestCases=obj.mSldvData.CounterExamples;
            case 'TestGeneration'
                obj.msldvDataTestCases=obj.mSldvData.TestCases;
            case 'DesignErrorDetection'
                obj.msldvDataTestCases=obj.mSldvData.CounterExamples;
            end

            obj.mModelH=modelH;

            obj.mTestComp=testComp;

            obj.mUseParallel=useParallel;
        end


        function validatedSldvData=runValidator(obj)


            obj.findTestCasestoValidate(obj.msldvDataTestCases,obj.mSldvData.Objectives);


            obj.buildGoalObjectiveMaps();


            validator=sldvprivate('getValidator',obj.mSldvData,obj.mModelH,...
            obj.mObjectiveToGoalMap,obj.mTestComp,obj.mGoalIDtoObjectiveMap);





            validator.isStandaloneValidator=true;


            validatedSldvData=validator.validate(obj.mtestCasestoValidate,obj.mUseParallel);
        end


        function isSldvDataConsistent(obj)
            checksum=Sldv.Compatibility.ChecksumCalculator(obj.mModelH);
            obj.mComponentChecksum=checksum.compute();
            obj.mCustomCodeChecksum=checksum.getCustomCodeInfo(obj.mModelH);

            sl_Checksum=obj.mSldvData.Checksum;
            if isequal(obj.mComponentChecksum.Checksum.Structural,sl_Checksum.ComponentChecksum.Structural)&&...
                isequal(obj.mComponentChecksum.Checksum.Parameter,sl_Checksum.ComponentChecksum.Parameter)&&...
                isequal(obj.mCustomCodeChecksum.SettingsChecksum,sl_Checksum.CustomCodeChecksum.SettingsChecksum)&&...
                isequal(obj.mCustomCodeChecksum.FullChecksum,sl_Checksum.CustomCodeChecksum.FullChecksum)
                return
            else







            end
        end
    end

    methods(Access=private)


        function buildGoalObjectiveMaps(obj)

            obj.mTestComp.createAnalysisContext();

            goals={obj.mSldvData.Objectives.goal};


            objIdxs=num2cell(1:numel(goals));


            obj.mGoalIDtoObjectiveMap=containers.Map(goals,objIdxs);


            obj.mObjectiveToGoalMap=containers.Map('KeyType','double','ValueType','any');


            for i=1:numel(goals)
                if ismember(obj.mSldvData.Objectives(i).testCaseIdx,obj.mtestCaseIds)
                    goal=obj.mTestComp.getGoal(goals{i});
                    obj.mObjectiveToGoalMap(i)=goal;
                else
                    obj.mObjectiveToGoalMap(i)='';
                end
            end
        end



        function findTestCasestoValidate(obj,testCases,sldvdata_Objectives)


            for tIdx=1:numel(testCases)
                objIdxs=testCases(tIdx).objectives;
                for ti=1:numel(objIdxs)
                    if(any(strcmp(sldvdata_Objectives(objIdxs(ti).objectiveIdx).status,["Satisfied - needs simulation","Falsified - needs simulation","Active Logic - needs simulation"])))
                        obj.mtestCaseIds=[obj.mtestCaseIds,tIdx];

                        obj.mtestCasestoValidate=[obj.mtestCasestoValidate,testCases(tIdx)];
                        break
                    end
                end
            end
        end
    end
end
