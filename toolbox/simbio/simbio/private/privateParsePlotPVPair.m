function options=privateParsePlotPVPair(varargin)











    options.treeNodeLabel='Run';
    validProperties={'title','xlabel','ylabel','legend','treeNodeLabel'};
    if rem(numel(varargin),2)~=0
        error(message('SimBiology:sbiotrellis:PLOT_OPTIONS_PARSE_ERROR1'));
    end
    for i=1:2:numel(varargin)
        if~ischar(varargin{i})
            error(message('SimBiology:sbiotrellis:PLOT_OPTIONS_PARSE_ERROR2'));
        end
        if~any(strcmp(validProperties,varargin{i}))
            error(message('SimBiology:sbiotrellis:PLOT_OPTIONS_PARSE_ERROR3',varargin{i}));
        else
            if~ischar(varargin{i+1})&&~iscell(varargin{i+1})
                error(message('SimBiology:sbiotrellis:PLOT_OPTIONS_PARSE_ERROR4',varargin{i}));
            else
                options.(varargin{i})=varargin{i+1};
            end
        end
    end
