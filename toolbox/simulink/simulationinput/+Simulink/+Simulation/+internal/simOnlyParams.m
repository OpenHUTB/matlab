function simOnlyParams=simOnlyParams()


    simOnlyParams=[
    "SkipParameterUpdate",...
    "ReturnDatasetRefInSimOut",...
"AllowPause"
    ];
    simOnlyParams=[simOnlyParams,slInternal('getCommandLineSimOptions')];
end

