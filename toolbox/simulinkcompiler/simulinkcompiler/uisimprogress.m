function simProgressComponent=uisimprogress(varargin)




























    try
        simProgressComponent=simulink.ui.control.SimulationProgress(varargin{:});
    catch ex
        error('Simulink:ui:SimProgress:unknownInput',ex.message);
    end
end
