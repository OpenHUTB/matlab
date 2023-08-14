

function toggleManualReview(cbinfo,~)
    studio=cbinfo.studio;


    mr_manager=slci.manualreview.Manager.getInstance;
    mr=mr_manager.getManualReview(studio);


    isOn=mr.getStatus;
    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);
    if~isOn
        mr.turnOn;

        cv=mr_manager.getCodeView(studio);

        cv.refresh(ctx.getCodeLanguage);

    end
    if(mr.hasDialog)
        mr.getDialog.setCodeLanguage(ctx.getCodeLanguage);
    end

    mr.refresh
end