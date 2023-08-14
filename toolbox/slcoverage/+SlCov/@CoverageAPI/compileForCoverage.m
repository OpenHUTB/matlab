function compileForCoverage(modelH)

    modelName=get_param(modelH,'name');
    cmdCompile=sprintf('%s([],[],[],''compileForCoverage'')',modelName);%#ok<NASGU>
    cmdTerm=sprintf('%s([],[],[],''term'')',modelName);%#ok<NASGU>
    try
        evalc('evalin(''base'',cmdCompile)');
    catch MEx
        try
            evalc('evalin(''base'',cmdTerm)');
        catch MEx1 %#ok<NASGU>
        end
        rethrow(MEx);
    end
    evalc('evalin(''base'',cmdTerm)');
