function irOpenToLine(scriptPath,lineNo)








    if isempty(scriptPath)||~ischar(scriptPath)
        return;
    end
    if scriptPath(1)~='#'
        opentoline(scriptPath,lineNo);
        return;
    end

    try
        [~,fcnId]=codergui.evalprivate('sfDecodeBlockPath',scriptPath);
        sf('Open',fcnId,lineNo-1,-2);
    catch ME %#ok<NASGU>
    end