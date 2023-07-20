

classdef Optimization_Debugging<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=Optimization_Debugging(env)
            id='Optimization_Debugging';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Finish';
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(obj)
            env=obj.Env;
            env.PreserveParameter=false;
            env.PreserveNamedSignal=false;
            env.setCommonSettings();


            env.setParamOptional('SuppressErrorStatus','off');
            env.setParamOptional('MultiInstanceErrorCode','warning');
            env.setParamOptional('MatFileLogging','on');
            env.setParamOptional('OptimizeBlockIOStorage','off');
            env.setParamOptional('EfficientFloat2IntCast','off');
            env.setParamOptional('InlineInvariantSignals','off');
            env.setParamOptional('UseSpecifiedMinMax','off');
            env.setParamOptional('CreateSILPILBlock','None');
            env.setParamOptional('GenerateComments','on');
            env.setParamOptional('MATLABFcnDesc','on');
            env.setParamOptional('MATLABSourceComments','on');
            env.setParamOptional('SimulinkBlockComments','on');
            env.setParamOptional('EnableCustomComments','on');
            env.setParamOptional('ForceParamTrailComments','on');
            env.setParamOptional('ReqsInCode','on');
            env.setParamOptional('ShowEliminatedStatement','on');
            env.setParamOptional('InsertBlockDesc','on');
            env.setParamOptional('SimulinkDataObjDesc','on');
            env.setParamOptional('SFDataObjDesc','on');
            env.setParamOptional('SFInvalidInputDataAccessInChartInitDiag','warning');
            env.setParamOptional('SFNoUnconditionalDefaultTransitionDiag','warning');
            env.setParamOptional('SFTransitionOutsideNaturalParentDiag','warning');
            env.setParamOptional('SFUnexpectedBacktrackingDiag','warning');
            env.setParamOptional('SFUnusedDataAndEventsDiag','warning');
            env.setParamOptional('MergeDetectMultiDrivingBlocksExec','error');
            env.setParamOptional('SFUnreachableExecutionPathDiag','warning');
            env.setParamOptional('SFTransitionActionBeforeConditionDiag','warning');
            env.setParamOptional('SFUndirectedBroadcastEventsDiag','warning');
            env.setParamOptional('BuildConfiguration','Debug');
            env.setParamOptional('BusAssignmentInplaceUpdate','off');
            env.setParamOptional('OptimizeBlockOrder','off');
            env.setParamOptional('OptimizeDataStoreBuffers','off');
            env.setParamOptional('DifferentSizesBufferReuse','off');


            if isempty(env.getParam('ObjectivePriorities'))
                env.setParamOptional('ObjectivePriorities',{{'Debugging'}});
            end
        end
    end
end


