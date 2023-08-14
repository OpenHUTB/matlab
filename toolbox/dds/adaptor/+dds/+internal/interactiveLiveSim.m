
function interactiveLiveSim(model,varargin)














    p=inputParser;
    addRequired(p,'model');
    addRequired(p,'enable');
    parse(p,model,varargin{:});
    arg=p.Results;
    isStringOrChar=@(x)(ischar(x)||isstring(x));
    enable=(islogical(arg.enable)&&arg.enable)||...
    (isStringOrChar(arg.enable)&&strcmpi(arg.enable,'on'));
    if enable
        slfeature('LiveSimulation',1);
        set_param(model,'LiveSimulationEnabled','on');
    else
        set_param(model,'LiveSimulationEnabled','off');
        slfeature('LiveSimulation',0);
    end
end