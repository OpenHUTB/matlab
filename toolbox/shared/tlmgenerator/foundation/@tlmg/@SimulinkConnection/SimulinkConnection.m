function this=SimulinkConnection(subsysPath,subsysName)





















    this=tlmg.SimulinkConnection;

    if(~isempty(subsysPath))
        system=[subsysPath,'/',subsysName];
    else
        system=subsysName;
    end

    if nargin<1
        system=bdroot;
    elseif ischar(system)||(isstring(system)&&isscalar(system))

    elseif ishandle(system)&&isa(system,'double')

        system=getfullname(system);
    else


        error(message('TLMGenerator:SimulinkConnection:invalidconstruction'));
    end




    try
        this.ModelName=bdroot(system);
        this.System=system;
        this.Subsystem=subsysName;
    catch me

        rethrow(me);
    end

