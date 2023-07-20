function openExplorer(modelToAnalyzeH)

    if slavteng('feature','Explorer')
        instance=SldvExplorer.ObjectiveExplorer;
        instance.run(modelToAnalyzeH);
    end