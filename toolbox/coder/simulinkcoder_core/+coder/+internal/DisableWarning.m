classdef DisableWarning<handle
    properties(Transient,SetAccess=private,GetAccess=private)
WarningStates
    end

    methods(Access=public)
        function this=DisableWarning(msgs)
            this.WarningStates=cellfun(@(msg)warning('off',msg),Simulink.ModelReference.Conversion.Utilities.cellify(msgs));
        end

        function delete(this)
            arrayfun(@(wstate)warning(wstate.state,wstate.identifier),this.WarningStates);
        end
    end
end
