function CheckMexDebuggingAndLaunchDebugger(modelH)
    if sfc('coder_options','debugGeneratedMex')
        SLCC.OOP.LaunchExternalDebuggerForModel(modelH,true);
    end
end

