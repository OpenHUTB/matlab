


classdef CounterexampleValidatorInPropertyProving<Sldv.Validator.Validator

    properties
        referencedModels;
        dirtyModels=[];
        notDirtyModels=[];
        assertBlks=[];
        proofObjectiveBlks=[];
        enabledParamOfAssertBlks={};
        enableAllAsserts=false;
        disableAllAsserts=false;
        stopWhenAssertionFailAssertBlks={};
        enableStopSimProofObjBlks={};
        blockParameterStruct=struct('Block',{},'ParameterName',{},'Value',{});


        covContextGuard=[];
    end
    properties(Hidden=true)
        simData;
        modelProofObjGoals;



        simDataMapForObjectives;


        noOpIdx;
    end
    methods
        function obj=CounterexampleValidatorInPropertyProving(sldvData,model,objectiveToGoalMap,...
            testcomp,goalIdToObjectiveIdMap)
            obj@Sldv.Validator.Validator(sldvData,model,objectiveToGoalMap,...
            testcomp,goalIdToObjectiveIdMap);


            obj.referencedModels=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
































            for i=1:length(obj.referencedModels)


                proofBlocksInCurrentModel=find_system(obj.referencedModels{i},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'masktype','Design Verifier Proof Objective');
                proofBlocksHInCurrentModel=get_param(proofBlocksInCurrentModel,'handle');

                assertBlocksInCurrentModel=find_system(obj.referencedModels{i},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'BlockType','Assertion');
                assertBlocksHInCurrentModel=get_param(assertBlocksInCurrentModel,'handle');

                obj.proofObjectiveBlks=[obj.proofObjectiveBlks;cell2mat(proofBlocksHInCurrentModel)];
                obj.assertBlks=[obj.assertBlks;cell2mat(assertBlocksHInCurrentModel)];

                if strcmp(get_param(obj.referencedModels{i},'dirty'),'on')
                    obj.dirtyModels=[obj.dirtyModels,get_param(obj.referencedModels{i},'handle')];
                else
                    obj.notDirtyModels=[obj.notDirtyModels,get_param(obj.referencedModels{i},'handle')];
                end
            end

            if strcmp(sldvData.AnalysisInformation.Options.Assertions,'EnableAll')
                obj.enableAllAsserts=true;
            elseif strcmp(sldvData.AnalysisInformation.Options.Assertions,'DisableAll')
                obj.disableAllAsserts=true;
            end




            if obj.enableAllAsserts||obj.disableAllAsserts
                obj.enabledParamOfAssertBlks=arrayfun(@(i)get_param(obj.assertBlks(i),...
                'Enabled'),1:length(obj.assertBlks),'UniformOutput',false);
                for blkIdx=1:length(obj.assertBlks)
                    obj.blockParameterStruct(end+1).Block=obj.assertBlks(blkIdx);
                    obj.blockParameterStruct(end).ParameterName='Enabled';
                    if obj.enableAllAsserts
                        obj.blockParameterStruct(end).Value='on';
                    else
                        obj.blockParameterStruct(end).Value='off';
                    end
                end
            end

            obj.stopWhenAssertionFailAssertBlks=arrayfun(@(i)get_param(obj.assertBlks(i),...
            'StopWhenAssertionFail'),1:length(obj.assertBlks),'UniformOutput',false);

            for blkIdx=1:length(obj.assertBlks)
                obj.blockParameterStruct(end+1).Block=obj.assertBlks(blkIdx);
                obj.blockParameterStruct(end).ParameterName='StopWhenAssertionFail';
                obj.blockParameterStruct(end).Value='off';
            end

            for blkIdx=1:length(obj.proofObjectiveBlks)
                try


                    obj.enableStopSimProofObjBlks{blkIdx}=get_param(obj.proofObjectiveBlks(blkIdx),'enableStopSim');
                catch Mex %#ok<NASGU>
                    obj.enableStopSimProofObjBlks{blkIdx}=[];


                    continue;
                end

                obj.blockParameterStruct(end+1).Block=obj.proofObjectiveBlks(blkIdx);
                obj.blockParameterStruct(end).ParameterName='enableStopSim';
                obj.blockParameterStruct(end).Value='off';
            end

            if~ischar(model)
                model=get_param(model,'Name');
            end

            obj.covContextGuard=SlCov.ContextGuard(model);

            obj.initSimulationData;
        end

        function initSimulationData(obj)
            obj.simData=struct();
            obj.simDataMapForObjectives=struct();
            obj.noOpIdx=[];
            obj.modelProofObjGoals=[];
        end

        function delete(obj)
            if obj.enableAllAsserts||obj.disableAllAsserts
                arrayfun(@(i)set_param(obj.assertBlks(i),'Enabled',...
                obj.enabledParamOfAssertBlks{i}),1:length(obj.assertBlks));
            end

            arrayfun(@(i)set_param(obj.assertBlks(i),'StopWhenAssertionFail',...
            obj.stopWhenAssertionFailAssertBlks{i}),1:length(obj.assertBlks));

            for i=1:length(obj.proofObjectiveBlks)
                if~isempty(obj.enableStopSimProofObjBlks{i})
                    set_param(obj.proofObjectiveBlks(i),'enableStopSim',obj.enableStopSimProofObjBlks{i});
                end
            end

            for i=1:length(obj.notDirtyModels)
                set_param(obj.notDirtyModels(i),'dirty','off');
            end
            for i=1:length(obj.dirtyModels)
                set_param(obj.dirtyModels(i),'dirty','on');
            end

            delete(obj.covContextGuard);
        end

        function updateObjectiveStatus(obj,ceObjId,status)
            ceId=ceObjId(1);
            objectiveId=ceObjId(2);
            goal=obj.objectiveToGoalMap(objectiveId);
            tGoalId=goal.getGoalMapId();
            goalResult=obj.testComp.getGoalResult(tGoalId,ceId);

            objStatus=struct('objective',[],'status',[]);
            objStatus.objective=objectiveId;
            objStatus.status=status;

            validatedStatus=obj.updateStatus(objStatus,goalResult.status);
            if~obj.isStandaloneValidator



                testComp=obj.testComp;
                force=false;
                testComp.updateValidatedGoals(tGoalId,string(validatedStatus),force,ceId)
            end
        end

        function validatedStatus=updateStatus(obj,objectiveWithStatus,currentStatus)
            validatedStatus=[];%#ok<NASGU>


            validatedStatus=currentStatus;

            switch objectiveWithStatus.status
            case{Sldv.Validator.ValidationStatus.IgnoredDueToBlockReplacement,...
                Sldv.Validator.ValidationStatus.NoCoverage,...
                Sldv.Validator.ValidationStatus.Unvalidated}


                if strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentStatus)
                    validatedStatus='GOAL_UNDECIDED_STUB';
                    obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
                end
            case Sldv.Validator.ValidationStatus.Success
                validatedStatus='GOAL_FALSIFIABLE';
                obj.sldvData.Objectives(objectiveWithStatus.objective).status='Falsified';
            case Sldv.Validator.ValidationStatus.RuntimeError

                if strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentStatus)
                    validatedStatus='GOAL_UNDECIDED_STUB';
                    obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
                else
                    validatedStatus='GOAL_UNDECIDED_RUNTIME_ERROR';
                    obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to runtime error';
                end
            case{Sldv.Validator.ValidationStatus.NotSuccess...
                ,Sldv.Validator.ValidationStatus.Inconclusive}
                if strcmp('GOAL_FALSIFIABLE_NEEDS_SIMULATION',currentStatus)
                    validatedStatus='GOAL_UNDECIDED_WITH_COUNTEREXAMPLE';
                    obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided with counterexample';

                elseif strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',currentStatus)
                    validatedStatus='GOAL_UNDECIDED_STUB';
                    obj.sldvData.Objectives(objectiveWithStatus.objective).status='Undecided due to stubbing';
                end
            end

        end

        function clearSimulationData(obj)
            obj.initSimulationData;
        end
    end

    methods(Static)

        function runOpts=getRunOpts(model)
            runOpts=sldvruntestopts;
            runOpts.coverageEnabled=true;
            cvto=cvtest(model);
            cvto.settings.decision=0;
            cvto.settings.condition=0;
            cvto.settings.mcdc=0;
            cvto.settings.designverifier=1;
            cvto.settings.relationalop=0;
            cvto.modelRefSettings.enable='on';
            cvto.modelRefSettings.excludeTopModel=0;
            cvto.emlSettings.enableExternal=1;
            cvto.sfcnSettings.enableSfcn=0;
            runOpts.coverageSetting=cvto;
            runOpts.fastRestart=1;
        end

        function foundError=findError(Mex,errorId)
            foundError=false;

            if strcmp(Mex.identifier,errorId)
                foundError=true;
                return;
            end

            for i=1:length(Mex.cause)
                foundError=Sldv.Validator.CounterexampleValidatorInPropertyProving.findError(Mex.cause{i},errorId);
                if foundError
                    return;
                end
            end
        end

    end
end
