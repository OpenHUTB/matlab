function varargout=view(varargin)






    stm.internal.util.checkLicense();

    mlock;
    persistent isSDILoaded;

    if isempty(isSDILoaded)
        isSDILoaded=1;
        Simulink.sdi.internal.startConnector();
    end

    browser='cef';
    debug=0;
    verbose=0;


    if nargin>1

        if 1==mod(nargin,2)
            error(message('stm:general:NotPairs'));
        end

        for i=1:nargin/2
            param=varargin{2*i-1};
            value=varargin{2*i};
            switch(param)
            case 'browser'
                browser=value;
            case 'debug'
                debug=value;
            case 'verbose'
                verbose=value;
            otherwise
                error(message('stm:general:InvalidPairs'));
            end
        end
    end

    viewInstance=stm.internal.ViewInstance.getInstance();
    start_simulink();


    stm.internal.Connector.on();


    stm.internal.loadLibrary();

    import com.mathworks.services.clipboardservice.ConnectorClipboardService;


    ConnectorClipboardService.getInstance();


    switch browser
    case 'cef'
        tempVarargout=viewInstance.launchCef(debug);
    otherwise
        tempVarargout=viewInstance.launchStm(browser,debug);
    end

    stm.internal.registerServices();
    if verbose
        varargout{1}=tempVarargout;
    end
end
