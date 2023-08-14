function gotoModel(modelH)










    studioApp=SLM3I.SLDomain.getLastActiveStudioAppWith(modelH);
    if isempty(studioApp)

        open_system(modelH);
        studioApp=SLM3I.SLDomain.getLastActiveStudioAppWith(modelH);
    end
    d=SLM3I.Util.getDiagram(modelH);
    studioApp.openAnyEditor(d.diagram);
    studio=studioApp.getStudio();
    studio.show;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if~cp.isInPerspective(studio)
        cp.turnOnPerspective(studio);
    end
    task=cp.getTask('CodeMapping');
    if task.isAutoOn(studio)
        task.turnOn(studio);
    end
end