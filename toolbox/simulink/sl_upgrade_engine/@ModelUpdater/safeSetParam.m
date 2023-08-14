function safeSetParam(block,varargin)





    try
        set_param(block,varargin{:})
    catch e
        [~,errmsg]=slprivate('getAllErrorIdsAndMsgs',e,...
        'concatenateIdsAndMsgs',true);
        MSLDiagnostic('SimulinkUpgradeEngine:engine:setParameterCaught',...
        ModelUpdater.cleanLocationName(block),...
        errmsg).reportAsWarning;
    end
