function listOfIncludes=inferHeaderDependenciesFromSrc(obj)

    assert(~isempty(obj.qualifiedSettings.CustomCode.SourceFiles),...
    'Source file is not expected to be empty during interface header computation!');

    codeInsightForInferringIncludes=polyspace.internal.codeinsight.CodeInsight('SourceFiles',internal.CodeImporter.Tools.convertToFullPath(...
    obj.qualifiedSettings.CustomCode.SourceFiles,...
    obj.qualifiedSettings.CustomCode.RootFolder),...
    'IncludeDirs',internal.CodeImporter.Tools.convertToFullPath(...
    obj.qualifiedSettings.CustomCode.IncludePaths,...
    obj.qualifiedSettings.CustomCode.RootFolder),...
    'Defines',obj.qualifiedSettings.CustomCode.Defines);

    options.DoSimulinkImportCompliance=true;
    options.Lang=obj.qualifiedSettings.CustomCode.Language;
    parseArgs=namedargs2cell(options);


    success=codeInsightForInferringIncludes.parse(parseArgs{:});
    if success
        listOfIncludes=codeInsightForInferringIncludes.CodeInfo.getHeaderInterface();
        if isempty(listOfIncludes)
            errmsg=MException(message('Simulink:CodeImporter:CannotInferHeaderFile'));
            throw(errmsg);
        end
    else
        baseE=MException(message('Simulink:CodeImporter:ParseUnsuccessful'));
        if isempty(codeInsightForInferringIncludes.Errors)
            causeE=MException(message('Simulink:CodeImporter:EmptyParseResult'));
        else
            causeE=MException('Simulink:CodeImporter:ParseErrors','%s',codeInsightForInferringIncludes.Errors);
        end
        baseE=addCause(baseE,causeE);
        throw(baseE);
    end
end