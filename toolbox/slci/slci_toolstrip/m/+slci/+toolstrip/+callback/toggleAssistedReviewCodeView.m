


function toggleAssistedReviewCodeView(cbinfo,~)

    studio=cbinfo.studio;
    ctx=slci.toolstrip.util.getSlciAppContext(studio);

    assert(strcmpi(ctx.getReviewMode,'AssistedReview'));

    mr_manager=slci.manualreview.Manager.getInstance;
    cv=mr_manager.getCodeView(studio);
    codeLanguage=ctx.getCodeLanguage();

    cv.refresh(codeLanguage);

end

