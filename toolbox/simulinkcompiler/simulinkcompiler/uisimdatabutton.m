function simButtonComponent=uisimdatabutton(varargin)








































    import matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily

    styleNames={...
    'saveoutput',...
'loadinput'...
    };

    classNames={...
    'simulink.ui.control.SaveOutputButton',...
'simulink.ui.control.LoadInputButton'...
    };

    defaultClassName='simulink.ui.control.SaveOutputButton';

    messageCatalogID='uisimdatabutton';

    try
        simButtonComponent=createComponentInFamily(...
        styleNames,...
        classNames,...
        defaultClassName,...
        messageCatalogID,...
        varargin{:});
    catch ex
        error('Simulink:ui:SimIOButton:unknownInput',...
        ex.message);
    end
