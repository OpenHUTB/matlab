classdef OverviewClass<handle

    properties(SetAccess=private)
Overview
    end

    methods


        function obj=OverviewClass(SortedPD)
            import solverprofiler.util.*
            obj.Overview=obj.makeOverviewStruct();

            mdl=SortedPD.getData('Model');
            tout=SortedPD.getData('Tout');
            profileTime=SortedPD.getData('ProfileTime');
            zcInfo=SortedPD.getData('ZcInfo');
            failureInfo=SortedPD.getData('FailureInfo');
            blockStateStats=SortedPD.getData('BlockStateStats');




            isFixedStep=strcmp(get_param(mdl,'SolverType'),'Fixed-step');
            isODEN=strcmpi(get_param(mdl,'Solver'),'oden');


            isAuto=regexpi(get_param(mdl,'Solver'),'Auto');
            compSolver=get_param(mdl,'CompiledSolverName');
            if isAuto
                obj.Overview.modelStats.solver.value=['auto(',compSolver,')'];
            else
                obj.Overview.modelStats.solver.value=compSolver;
            end
            obj.Overview.modelStats.tStart.value=tout(1);
            obj.Overview.modelStats.tStop.value=tout(end);

            if isFixedStep||isODEN
                obj.Overview.modelStats.absTol.value='N/A';
                obj.Overview.modelStats.autoScaleAbsTol.value='N/A';
                obj.Overview.modelStats.relTol.value='N/A';
            else
                isAuto=regexpi(get_param(mdl,'RelTol'),'Auto');
                if isAuto
                    obj.Overview.modelStats.relTol.value=1e-3;
                else
                    obj.Overview.modelStats.relTol.value=...
                    utilGetScalarValue(get_param(mdl,'RelTol'));
                end

                isAuto=regexpi(get_param(mdl,'AbsTol'),'Auto');
                if isAuto
                    try
                        obj.Overview.modelStats.absTol.value=...
                        min(1e-6,1e-3*obj.Overview.modelStats.relTol.value);
                    catch
                        obj.Overview.modelStats.absTol.value=...
                        utilGetScalarValue(get_param(mdl,'AbsTol'));
                    end
                else
                    obj.Overview.modelStats.absTol.value=...
                    utilGetScalarValue(get_param(mdl,'AbsTol'));
                end
                obj.Overview.modelStats.autoScaleAbsTol.value=...
                get_param(mdl,'AutoScaleAbsTol');
            end

            obj.Overview.modelStats.numBlocksWithState.value=blockStateStats.getNumBlocksWithState();
            obj.Overview.modelStats.numStates.value=blockStateStats.getNumberOfStates();


            if isFixedStep
                obj.Overview.stepStats.hmax.value='N/A';
                obj.Overview.stepStats.percentOnHmax.value='N/A';
            else
                obj.Overview.stepStats.hmax.value=SortedPD.getHmax();
                obj.Overview.stepStats.percentOnHmax.value=SortedPD.getHmaxRatio();
            end


            if isFixedStep||isODEN
                obj.Overview.stepStats.hmin.value='N/A';
            else
                obj.Overview.stepStats.hmin.value=get_param(mdl,'MinStep');
                isAuto=regexpi(obj.Overview.stepStats.hmin.value,'Auto');
                if~isAuto
                    obj.Overview.stepStats.hmin.value=...
                    utilGetScalarValue(obj.Overview.stepStats.hmin.value);
                end
            end

            obj.Overview.stepStats.numSteps.value=length(tout)-1;
            obj.Overview.stepStats.havg.value=(tout(end)-tout(1))/(length(tout)-1);
            obj.Overview.stepStats.profileTime.value=profileTime;
            obj.Overview.stepStats.profileSimTimeRatio.value=profileTime/(tout(end)-tout(1));



            obj.Overview.eventStats.numZCSrc.value=zcInfo.numSrcs();
            obj.Overview.eventStats.numZCSrcTrg.value=zcInfo.numTriggerdSrcs();
            obj.Overview.eventStats.numZC.value=zcInfo.totalZcNum();

            obj.Overview.eventStats.numReset.value=SortedPD.getTotalResetNum(0);
            obj.Overview.eventStats.numZCReset.value=SortedPD.getTotalResetNum(1);
            obj.Overview.eventStats.numDiscrete.value=SortedPD.getTotalResetNum(2);
            obj.Overview.eventStats.numZOH.value=SortedPD.getTotalResetNum(3);
            obj.Overview.eventStats.numInitial.value=SortedPD.getTotalResetNum(4);
            obj.Overview.eventStats.numBlock.value=SortedPD.getTotalResetNum(5);
            obj.Overview.eventStats.numInternal.value=SortedPD.getTotalResetNum(6);

            obj.Overview.eventStats.numJacobian.value=length(SortedPD.getJacobianUpdateTime());

            obj.Overview.eventStats.numFailure.value=failureInfo.getTotalFailureNum(0);
            obj.Overview.eventStats.numTolerance.value=failureInfo.getTotalFailureNum(1);
            obj.Overview.eventStats.numNewton.value=failureInfo.getTotalFailureNum(2);
            obj.Overview.eventStats.numInfinite.value=failureInfo.getTotalFailureNum(3);
            obj.Overview.eventStats.numDerivInfinite.value=failureInfo.getTotalFailureNum(4);
            obj.Overview.eventStats.numDAE.value=failureInfo.getTotalFailureNum(5);
        end


        function delete(obj)
            obj.Overview=[];
        end

        function value=getAbsoluteTolerance(obj)
            value=obj.Overview.modelStats.absTol.value;
        end


        function content=getOverviewTableContent(obj)
            import solverprofiler.util.*

            strModelInfo=utilDAGetString('modelInfo');
            strStepInfo=utilDAGetString('stepInfo');
            strEventInfo=utilDAGetString('eventInfo');


            content=cell(27,2);
            content{1,1}=strModelInfo;
            content{1,2}='';

            fNames=fieldnames(obj.Overview.modelStats);
            for i=1:length(fNames)
                content{i+1,1}=obj.Overview.modelStats.(fNames{i}).description;
                content{i+1,2}=utilFormatToString(obj.Overview.modelStats.(fNames{i}).value);
            end
            content{10,1}='';
            content{10,2}='';


            content{11,1}=strStepInfo;
            content{11,2}='';
            fNames=fieldnames(obj.Overview.stepStats);
            for i=1:length(fNames)
                content{i+11,1}=obj.Overview.stepStats.(fNames{i}).description;
                content{i+11,2}=utilFormatToString(obj.Overview.stepStats.(fNames{i}).value);
            end
            content{19,1}='';
            content{19,2}='';


            content{20,1}=strEventInfo;
            content{20,2}='';
            fNames=fieldnames(obj.Overview.eventStats);
            for i=1:length(fNames)
                content{i+20,1}=obj.Overview.eventStats.(fNames{i}).description;
                content{i+20,2}=utilFormatToString(obj.Overview.eventStats.(fNames{i}).value);
                if i>=3&&(str2double(content{i+20,2})>0)
                    content{i+20,2}=content{i+20,2};
                end
            end





            indent=[char(160),char(160),char(160),char(160)];
            for i=6:11
                content{20+i,1}=[indent,content{i+20,1}];
            end
            for i=13:17
                content{20+i,1}=[indent,content{i+20,1}];
            end
        end

        function simplifiedOverview=getSimplifiedOverview(obj)
            simplifiedOverview=obj.makeSimplifiedOverviewStruct();

            simplifiedOverview.solver=obj.Overview.modelStats.solver.value;
            simplifiedOverview.tStart=obj.Overview.modelStats.tStart.value;
            simplifiedOverview.tStop=obj.Overview.modelStats.tStop.value;
            simplifiedOverview.absTol=obj.Overview.modelStats.absTol.value;
            simplifiedOverview.relTol=obj.Overview.modelStats.relTol.value;

            simplifiedOverview.hMax=obj.Overview.stepStats.hmax.value;
            simplifiedOverview.hAverage=obj.Overview.stepStats.havg.value;
            simplifiedOverview.steps=obj.Overview.stepStats.numSteps.value;
            simplifiedOverview.profileTime=obj.Overview.stepStats.profileTime.value;

            simplifiedOverview.zcNumber=obj.Overview.eventStats.numZC.value;
            simplifiedOverview.resetNumber=obj.Overview.eventStats.numReset.value;
            simplifiedOverview.jacobianNumber=obj.Overview.eventStats.numJacobian.value;
            simplifiedOverview.exceptionNumber=obj.Overview.eventStats.numFailure.value;
        end
    end

    methods(Static)
        function overview=makeOverviewStruct()

            pair=@(key)struct('description',...
            DAStudio.message(['Simulink:solverProfiler:',key]),'value',[]);


            modelStats=struct(...
            'solver',pair('compiledSolver'),...
            'numBlocksWithState',pair('blocksWithState'),...
            'numStates',pair('allStates'),...
            'tStart',pair('startTime'),...
            'tStop',pair('stopTime'),...
            'absTol',pair('absoluteTolerance'),...
            'autoScaleAbsTol',pair('autoScaleAbsTol'),...
            'relTol',pair('relativeTolerance'));


            stepStats=struct(...
            'hmax',pair('maxStepSize'),...
            'hmin',pair('minStepSize'),...
            'havg',pair('averageStepSize'),...
            'percentOnHmax',pair('percentageOfMaxSteps'),...
            'numSteps',pair('totalSteps'),...
            'profileTime',pair('profileTime'),...
            'profileSimTimeRatio',pair('profileSimTimeRatio'));


            eventStats=struct(...
            'numZCSrc',pair('zcSources'),...
            'numZCSrcTrg',pair('zcSourcesTriggered'),...
            'numZC',pair('totalZC'),...
            'numJacobian',pair('totalJacobianUpdate'),...
            'numReset',pair('totalSolverResets'),...
            'numZCReset',pair('resetColumnName2'),...
            'numDiscrete',pair('resetColumnName3'),...
            'numZOH',pair('resetColumnName4'),...
            'numInitial',pair('resetColumnName5'),...
            'numBlock',pair('resetColumnName6'),...
            'numInternal',pair('resetColumnName7'),...
            'numFailure',pair('totalFailures'),...
            'numTolerance',pair('errorExceedsTolerance'),...
            'numNewton',pair('newtonIterationFailure'),...
            'numInfinite',pair('infiniteState'),...
            'numDerivInfinite',pair('infiniteDerivative'),...
            'numDAE',pair('daeMinStepSizeViolation'));



            overview=struct(...
            'modelStats',modelStats,...
            'stepStats',stepStats,...
            'eventStats',eventStats);
        end


        function overview=makeSimplifiedOverviewStruct()
            overview=struct(...
            'solver','',...
            'tStart','',...
            'tStop','',...
            'absTol','',...
            'relTol','',...
            'hMax','',...
            'hAverage','',...
            'steps','',...
            'profileTime','',...
            'zcNumber','',...
            'resetNumber','',...
            'jacobianNumber','',...
            'exceptionNumber','');
        end
    end


end