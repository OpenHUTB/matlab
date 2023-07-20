

function svgString=DispatchCommand(obj,functionName,commandArguments)
    funcName=['Simulink.Mask.process_',functionName];
    func=str2func(funcName);

    svgString=func(obj,commandArguments);
end