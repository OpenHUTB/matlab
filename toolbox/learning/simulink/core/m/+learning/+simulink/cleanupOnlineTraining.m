function cleanupOnlineTraining

    hidden_figures=findobj(0,'Visible','off');

    for idx=1:numel(hidden_figures)
        close(hidden_figures(idx))
    end

    if bdIsLoaded('signalChecks')
        bdclose('signalChecks');
    end
end
