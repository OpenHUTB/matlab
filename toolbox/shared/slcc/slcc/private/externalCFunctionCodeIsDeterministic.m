function usesOnlyDeterministic=externalCFunctionCodeIsDeterministic(modelH,blockH)





    defaultDeterministic=get_param(modelH,'DefaultCustomCodeDeterministicFunctions');
    if strcmpi(defaultDeterministic,'All')
        usesOnlyDeterministic=true;
        return;
    end
    if strcmpi(defaultDeterministic,'None')
        deterministicFcnList='';
    else
        deterministicFcnList=get_param(modelH,'CustomCodeDeterministicFunctions');
    end

    blockCode=get_param(blockH,'OutputCode');

    exportedSyms=slcc('getExportedSymbols',modelH);
    fcnsToCheck=setdiff(exportedSyms.functions,strsplit(deterministicFcnList,','));
    varsToCheck=exportedSyms.globals;

    if isempty(fcnsToCheck)&&isempty(varsToCheck)
        usesOnlyDeterministic=true;
        return;
    end

    feOptions=cgxeprivate('getFrontEndOptionsFromModel',modelH);
    cs=getActiveConfigSet(modelH);
    includes=get_param(cs,'SimCustomHeaderCode');

    feOptions.PreprocOutput=[tempname(),'.i'];
    clr=onCleanup(@()deleteFile(feOptions.PreprocOutput));


    feOptions.ErrorOutput=[tempname(),'.err'];
    clr2=onCleanup(@()deleteFile(feOptions.ErrorOutput));

    feOptions.DoPreprocessOnly=true;
    feOptions.Preprocessor.KeepComments=false;
    feOptions.Preprocessor.KeepLineDirectives=false;

    [~,fcnName]=fileparts(feOptions.PreprocOutput);

    txtToParse=[includes,newline...
    ,'void ',fcnName,'() {',newline...
    ,blockCode,newline...
    ,'}'...
    ];

    [~]=internal.cxxfe.FrontEnd.parseText(txtToParse,feOptions);

    parsedText=fileread(feOptions.PreprocOutput);
    parsedBlockText=extractAfter(parsedText,fcnName);

    symDelim=regexpPattern('[^\w\d_]');
    symPattern=lookBehindBoundary(symDelim)+[fcnsToCheck,varsToCheck]+lookAheadBoundary(symDelim);

    usesOnlyDeterministic=~contains(parsedBlockText,symPattern);

end

function deleteFile(fileName)
    if isfile(fileName)
        delete(fileName);
    end
end