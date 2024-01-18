function invoke(hDOORS,cmdStr)
    fullCmd=[sprintf('pragma runLim, 0\n')...
    ,cmdStr];

    hDOORS.runStr(fullCmd);
end
