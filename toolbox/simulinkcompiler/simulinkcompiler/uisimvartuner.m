function varTunerComponent=uisimvartuner(varargin)









































    try
        varTunerComponent=simulink.ui.control.VariableTuner(varargin{:});
    catch ex
        error('Simulink:ui:SimVariableTuner:unknownInput',ex.message);
    end
end
