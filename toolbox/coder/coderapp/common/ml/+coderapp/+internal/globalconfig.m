function varargout=globalconfig(action,varargin)




    if nargin>0&&~startsWith(action,'-')
        args=[char(action),varargin];
        if nargin>1
            action='-set';
        else
            action='-get';
        end
    else
        if nargin==0
            action='-view';
        end
        args=varargin;
    end

    varargout={};
    import coderapp.internal.gc.ConfigurationFacade;

    switch action
    case '-get'
        narginchk(1,2);
        varargout{1}=ConfigurationFacade.getValue(args{:});
    case{'-set','-internalSet'}
        ConfigurationFacade.setValue(action=="-set",cell2struct(args(2:2:end),args(1:2:end),2));
    case '-reset'
        if isempty(args)
            ConfigurationFacade.resetAll();
        else
            ConfigurationFacade.resetKeys(args);
        end
    case '-view'
        narginchk(0,1);
        if ConfigurationFacade.CAN_VIEW
            dialog=manageDialog('show');
            if nargout~=0
                varargout{1}=dialog;
            end
        else
            dump();
        end
    case '-list'
        narginchk(0,1);
        dump();
    end
end


function varargout=manageDialog(mode)
    persistent singleton lifecycleBinder;
    if~isempty(singleton)&&~isvalid(singleton)
        singleton=[];
        lifecycleBinder=[];
    end
    switch mode
    case 'show'
        if isempty(singleton)
            lifecycleBinder=onCleanup(@()manageDialog('clear'));
            configuration=coderapp.internal.gc.ConfigurationFacade.getConfiguration();
            cleanup=overrideWebClientSettings();%#ok<NASGU>
            controller=coderapp.internal.config.ui.ConfigDialogController(...
            'ProductionKey','script','ResyncProductionOnFocus',false);
            singleton=coderapp.internal.config.ui.GenericConfigDialog(configuration,...
            Controller=controller,EnableLogging=false);
            singleton.Title='Internal Coder Settings';
            singleton.addlistener('ObjectBeingDestroyed',@(~,~)munlock);
            mlock;
        else
            singleton.show();
        end
        varargout{1}=singleton;
    case 'get'
        varargout{1}=singleton;
    case 'clear'
        if~isempty(singleton)
            singleton.delete();
            singleton=[];
            lifecycleBinder=[];
        end
    end
end


function cleanup=overrideWebClientSettings()
    configuration=coderapp.internal.gc.ConfigurationFacade.getConfiguration();
    origFactory=codergui.ReportServices.WebClientFactory.resolve();
    [origDebug,origDebugger,origBreak]=configuration.get('WebDebugMode','WebDebugger','WebBreakOnInit');
    cleanup=onCleanup(@()restoreWebClientSettings(origFactory,origDebug,origDebugger,origBreak));
    codergui.ReportServices.setWebClientType('webwindow');
    configuration.set(struct('WebDebugMode',false,'WebDebugger',false,'WebBreakOnInit',false));
end


function restoreWebClientSettings(origFactory,origDebug,origDebugger,origBreak)
    codergui.ReportServices.setWebClientType(origFactory);
    configuration=coderapp.internal.gc.ConfigurationFacade.getConfiguration();
    configuration.set(struct('WebDebugMode',origDebug,'WebDebugger',origDebugger,'WebBreakOnInit',origBreak));
end


function dump()
    configuration=coderapp.internal.gc.ConfigurationFacade.getConfiguration();
    keys=sort(coderapp.internal.gc.ConfigurationFacade.getKeys());
    modified=configuration.isUserModified(keys);
    dialog=manageDialog('get');

    fprintf('\n');
    for i=1:numel(keys)
        if~isempty(dialog)
            keyStr=sprintf('<a href="matlab: goTo(coderapp.internal.globalconfig(''-view''), ''%s'')">%s</a>',...
            keys{i},keys{i});
        else
            keyStr=keys{i};
        end
        valStr=configuration.getScriptCode(keys{i});
        if modified(i)
            valStr=sprintf('<a href="matlab: coderapp.internal.globalconfig(''-reset'', ''%s''); disp(''Resetting %s'')">%s</a>',...
            keys{i},keys{i},valStr);
        end
        fprintf('\t%s: %s\n',keyStr,valStr);
    end
    fprintf('\n');
end