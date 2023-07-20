
function checkFunctionSupportForTarget(fcnName,dlTarget,unsupportedTargetList)

    if any(strcmpi(dlTarget,unsupportedTargetList))
        error(message('dlcoder_spkg:cnncodegen:FunctionUnsupportedForTargetLib',fcnName,dlTarget));
    end
end
