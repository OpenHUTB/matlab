function warmupProgrammingAids

    featureValue=feature('TabCompletionUseHistory');
    cleanupObj=onCleanup(@()feature('TabCompletionUseHistory',featureValue));
    feature('TabCompletionUseHistory',0);

    s=settings;
    if~s.matlab.editor.codingui.Prewarm.hasTemporaryValue
        s.matlab.editor.codingui.Prewarm.TemporaryValue=0;
        builtin('_programmingAidsTest','','plot(',5,struct,'startup',false,struct([]),false);
    end
end

