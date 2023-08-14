function varargout=view(varargin)


    persistent isSDILoaded;

    if isempty(isSDILoaded)
        isSDILoaded=1;
        Simulink.sdi.startConnector();
    end

    p=inputParser();
    p.addParameter('browser','cef',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    p.addParameter('debug',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});

    start_simulink();


    connector.ensureServiceOn;

    import com.mathworks.services.clipboardservice.ConnectorClipboardService;


    ConnectorClipboardService.getInstance();


    viewInstance=sltest.assessments.internal.ViewInstance.getInstance();
    switch p.Results.browser
    case 'cef'
        tempVarargout=viewInstance.launchCef(p.Results.debug);
    otherwise
        tempVarargout=viewInstance.launchAssessmentEditor(p.Results.browser,p.Results.debug);
    end

    if nargout>0
        varargout{1}=tempVarargout;
    end
end
