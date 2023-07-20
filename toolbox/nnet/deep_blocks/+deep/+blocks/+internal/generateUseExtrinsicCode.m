function[lines,extrinsicVar]=generateUseExtrinsicCode(simSupported)

    extrinsicVar="useExtrinsic";

    isSimLine="isSim = coder.target('sfun');";
    simSupportedLine="simSupported = "+string(simSupported)+";";
    useExtrinsicLine=extrinsicVar+" = isSim && ~simSupported;";

    lines=join([isSimLine,simSupportedLine,useExtrinsicLine],newline);

end