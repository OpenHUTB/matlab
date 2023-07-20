function simTarget=uisimtarget(varargin)





























    try
        simTarget=simulink.SimulationTarget(varargin{:});
    catch ex
        error('Simulink:ui:SimTarget:unknownInput',ex.message);
    end
end
