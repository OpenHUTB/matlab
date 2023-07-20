function varargout=trackingScenarioDesigner(varargin)

























    if~isempty(varargin)&&strcmp(varargin{1},'-debug')

        h=fusion.internal.scenarioApp.Designer('-debug');
        varargin=varargin(2:end);
    else
        try
            h=fusion.internal.scenarioApp.Designer;
        catch me
            throw(me);
        end
    end

    open(h,varargin{:});

    if nargout
        varargout={h};
    end

