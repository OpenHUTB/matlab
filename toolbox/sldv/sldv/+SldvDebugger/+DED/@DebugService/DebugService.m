classdef DebugService<SldvDebugger.DebugService




    methods
        function obj=DebugService(model,sldvData)


            obj@SldvDebugger.DebugService(model,sldvData);
        end

        function testCase=getTestCase(obj,idx)


            testCase=obj.sldvData.CounterExamples(idx);
        end

        function simInputValues=getSimInputValues(obj,idx)

            sldvDataSLDataSet=Sldv.DataUtils.convertTestCasesToSLDataSet(obj.sldvData);
            simInputValues=sldvDataSLDataSet.CounterExamples(idx);
        end

        function mapKey=getCriteriaMapKey(obj,~)

            mapKey=string(obj.DebugCtx.curObjId);
        end

        function status=isObjectiveDebuggable(obj,objectiveId)

            allowedObjectiveStatuses={'Falsified','Falsified - needs simulation',...
            'Undecided with counterexample','Falsified - No Counterexample'};
            objectiveStatus=obj.sldvData.Objectives(objectiveId).status;


            status=any(strcmpi(objectiveStatus,allowedObjectiveStatuses));
        end

        function simButtonEnableMessage=getSimButtonEnableMessage(~)

            simButtonEnableMessage=getString(message('Sldv:DebugUsingSlicer:SimulationButtonEnabledMessage'));
        end

        function messageTag=getProgressIndicatorToLoadTestCase(~)

            messageTag='Sldv:DebugUsingSlicer:ProgressIndicatorLoadTestCase';
        end

        function messageTag=getProgressIndicatorStepToTime(~)

            messageTag='Sldv:DebugUsingSlicer:ProgressIndicatorStepToViolationTime';
        end

        function messageTag=getCriteriaDescription(~)

            messageTag='Sldv:DebugUsingSlicer:CriteriaDescriptionForDED';
        end
    end
end

