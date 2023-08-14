function obj=mqttclient(varargin)




    try
        obj=icomm.mqtt.Client(varargin{:});
    catch errExp
        throwAsCaller(errExp);
    end

