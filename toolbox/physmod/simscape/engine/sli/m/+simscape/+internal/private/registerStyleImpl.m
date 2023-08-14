function registerStyleImpl(varargin)

    defaultColor=[0,0,0];
    defaultStroke='-';
    defaultWidth=1.5;

    p=inputParser;
    p.addRequired('StyleName',@isstr);
    p.addParameter('StyleSheet','MathWorks',@isstr);
    p.addParameter('Color',defaultColor,@(x)(isnumeric(x)&&numel(x)==3&&all(x>=0)&&all(x<=255)&&all(floor(x)==ceil(x))));
    p.addParameter('Stroke',defaultStroke,@isstr);
    p.addParameter('Width',defaultWidth,@isscalar);

    p.parse(varargin{:});
    result=p.Results;
    if~isempty(result.StyleName)
        result.StyleName=['network_engine_domain.',result.StyleName];
    end
    builtin('_simscape_add_style',result);

end
