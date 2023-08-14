classdef(Sealed)SignalEditorSerializer<Simulink.SimulationData.SerializeInput.FromWksSerializer





    methods(Access=public)
        function throwError(this,~,errMsg,varargin)
            parent=get_param(this.currBlock,'Parent');
            msgID='Simulink:SimInput:SignalEditorError';
            msg=message(msgID,parent);
            rtInpException=MSLException(msg);

            causeObj=message(errMsg,varargin{:});
            causeException=MSLException(causeObj);

            rtInpException=addCause(rtInpException,causeException);
            throwAsCaller(rtInpException);
        end
    end

end
