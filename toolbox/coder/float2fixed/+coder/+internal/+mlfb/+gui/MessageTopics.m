


classdef(Sealed)MessageTopics<coder.internal.gui.MessageTopicWrapper
    enumeration

        CodeViewStateChange(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.VIEW_STATE_TOPIC)
        FixedPointParamChange(com.mathworks.toolbox.coder.fixedpoint.FixedPointConstants.FP_PARAM_CHANGE_TOPIC)
        InternalCodeViewState(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.INTERNAL_STATE_TOPIC)
        ActionTrigger(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.ACTION_TRIGGER_TOPIC)


        BackendPush(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.BACKEND_PUSH_TOPIC)
        SimulinkUpdate(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.SIMULINK_STATE_TOPIC)
        StateflowUpdate(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.STATEFLOW_UI_UPDATE_TOPIC)
        CodeViewManipulation(com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.VIEW_MANIPULATION_TOPIC)
    end
end