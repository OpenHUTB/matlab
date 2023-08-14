function hd=handle(varargin)














    inputArgs=parseInputArgs(varargin{:});
    modelName=inputArgs.Model;
    isMLHDLC=inputArgs.isMLHDLC;


    if isMLHDLC

        hc=hdlcurrentdriver;
    else

        hc=downstream.CodeGenInfo.getCodeGenHandle(modelName);
    end


    hd=hc.DownstreamIntegrationDriver;

end


function inputArgs=parseInputArgs(varargin)


    persistent p;
    if isempty(p)
        p=inputParser;
        p.addParamValue('Model','');
        p.addParamValue('isMLHDLC',false);
    end

    p.parse(varargin{:});
    inputArgs=p.Results;

end