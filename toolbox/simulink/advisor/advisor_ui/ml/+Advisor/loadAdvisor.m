function loadAdvisor(system,varargin)


    if nargin==0
        error('Advisor:ui:advisor_nomodel_specified',DAStudio.message('Advisor:ui:advisor_nomodel_specified'));
    end

    p=inputParser;
    p.addParameter('systemselector','off');
    p.addParameter('configuration','');
    p.addParameter('debug',false);
    p.parse(varargin{:})
    args=p.Results;

    if isnumeric(system)

        system=Simulink.ID.getSID(system);
    end

    modelname=bdroot(system);

    if args.debug
        Advisor.AdvisorWindow.debugMode(true);
        Advisor.AdvisorWindow.browserMode('Chrome');
    end

    ma_ui=Advisor.AdvisorWindow(modelname);
    if strcmp(args.systemselector,'off')

        ma_ui.setSystem(system);
    else
        ma_ui.setSystem('');
    end

    if~isempty(args.configuration)
        ma_ui.setConfiguration(args.configuration);
    end

    ma_ui.open();



end