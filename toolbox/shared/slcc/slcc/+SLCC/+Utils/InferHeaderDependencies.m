function hdrFiles=InferHeaderDependencies(ccInfo)
    ccSettings=ccInfo.customCodeSettings;
    codeInsight=polyspace.internal.codeinsight.CodeInsight(...
    'SourceFiles',ccSettings.userSources,...
    'IncludeDirs',ccSettings.userIncludeDirs,...
    'Defines',string(CGXE.CustomCode.extractUserDefines(ccSettings.customUserDefines)));

    options.DoSimulinkImportCompliance=true;
    options.Lang=ccInfo.lang;
    parseArgs=namedargs2cell(options);


    success=codeInsight.parse(parseArgs{:});
    if success
        hdrFiles=codeInsight.CodeInfo.getHeaderInterface();
    else
        if isempty(codeInsight.Errors)
            causeE=MSLException([],message('Simulink:CodeImporter:EmptyParseResult'));
        else
            causeE=MSLException([],'Simulink:CodeImporter:ParseErrors','%s',codeInsight.Errors);
        end
        parseErrMsg=message('Simulink:CustomCode:InferringHeadersFailed');
        parseErrSLDiag=MSLException([],parseErrMsg);
        parseErrSLDiag=addCause(parseErrSLDiag,causeE);
        throw(parseErrSLDiag);
    end
end