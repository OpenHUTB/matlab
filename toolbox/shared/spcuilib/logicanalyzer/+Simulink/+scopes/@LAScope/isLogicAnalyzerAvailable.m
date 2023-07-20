function isAvailable=isLogicAnalyzerAvailable()








    persistent isFirstCall;
    if isempty(isFirstCall)
        isFirstCall=(slfeature('slLogicAnalyzerApp')>0)&&...
        (dig.isProductInstalled('DSP System Toolbox')||dig.isProductInstalled('SoC Blockset'));
    end
    isAvailable=isFirstCall;
end