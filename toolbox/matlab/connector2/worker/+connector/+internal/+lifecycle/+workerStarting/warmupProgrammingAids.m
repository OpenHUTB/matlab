function warmupProgrammingAids

    featureValue=feature('TabCompletionUseHistory');
    cleanupObj=onCleanup(@()feature('TabCompletionUseHistory',featureValue));
    feature('TabCompletionUseHistory',0);

    builtin('_programmingAidsTest','','plot',4,struct,true,false,struct([]),false);
    builtin('_programmingAidsTest','','plot(',5,struct,true,false,struct([]),false);
    builtin('_programmingAidsTest','','plot(',5,struct,true,false,struct([]),false);
end


