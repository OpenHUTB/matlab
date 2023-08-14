
function respondToPerspective(h,eventData)

    perspectiveOn=eventData.state;
    modelH=eventData.modelH;
    studio=eventData.studio;




    if~isempty(studio)
        modelH=studio.App.blockDiagramHandle;
    end

    if perspectiveOn
        slreq.toolstrip.openCloseReqEditorApp(true,modelH,studio);
    else
        slreq.toolstrip.openCloseReqEditorApp(false,modelH,studio);
    end

end
