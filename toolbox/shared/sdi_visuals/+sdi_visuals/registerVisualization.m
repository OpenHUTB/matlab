function registerVisualization(varargin)






































    p=inputParser;
    p.addParameter('id','',@(x)validate_parameter(x));
    p.addParameter('name','',@(x)validate_parameter(x));
    p.addParameter('configuration','',@(x)validate_parameter(x));
    p.addParameter('license','',@(x)validate_parameter(x));

    p.parse(varargin{:});
    params=p.Results;

    sdi_visuals.registerVisual(params.id,params.name,params.configuration,params.license);
end


function ret=validate_parameter(x)
    ret=ischar(x)||(isstring(x)&&isscalar(x));
end