function view(varargin)

    p=inputParser;
    p.addOptional('tab',Simulink.sdi.GUITabType.InspectSignals,@(x)isa(x,'Simulink.sdi.GUITabType'));
    p.addOptional('sigID',0,@(x)validate_id(x));
    p.addOptional('baselineID',0,@(x)validate_id(x));
    p.addOptional('compareToID',0,@(x)validate_id(x));
    p.addOptional('comparisonID',0,@(x)validate_id(x));
    try
        p.parse(varargin{:});
    catch me
        error(message('SDI:sdi:ViewAPIError'));
    end

    Simulink.sdi.Instance.open(varargin{:});
end


function ret=validate_id(arg)
    ret=isnumeric(arg)&&isscalar(arg);
end
