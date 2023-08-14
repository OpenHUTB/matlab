


function toggleCodeView(cbinfo,~)

    studio=cbinfo.studio;
    ctx=slci.toolstrip.util.getSlciAppContext(studio);

    assert(strcmpi(ctx.getReviewMode,'AutomaticReview'));

    vm_studio=slci.view.Studio.getFromStudio(studio);
    vm_codeview=vm_studio.getCodeView();

    vm_codeview.turnOn();
end

