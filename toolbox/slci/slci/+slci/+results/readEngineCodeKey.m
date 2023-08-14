



function[codeKey,codeFile,lineNum]=readEngineCodeKey(engineCodeKey)


    codeKey=engineCodeKey;

    [codePath,codeFile,lineNum]=slci.results.splitCodeLoc(engineCodeKey);


    if~isempty(codePath)
        codeFile=[codePath,filesep,codeFile];
    end

end
