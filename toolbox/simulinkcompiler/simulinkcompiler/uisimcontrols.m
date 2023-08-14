function simControlsComponent=uisimcontrols(varargin)












































    import matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily

    styleNames={...
    'simulink',...
'slrt'...
    };

    classNames={...
    'simulink.ui.control.SimulationControls',...
'slrealtime.ui.control.StartStopButton'...
    };

    defaultClassName='simulink.ui.control.SimulationControls';

    messageCatalogID='uisimcontrols';

    try
        simControlsComponent=createComponentInFamily(...
        styleNames,...
        classNames,...
        defaultClassName,...
        messageCatalogID,...
        varargin{:});
    catch ex
        error('Simulink:ui:SimButton:unknownInput',...
        ex.message);
    end
