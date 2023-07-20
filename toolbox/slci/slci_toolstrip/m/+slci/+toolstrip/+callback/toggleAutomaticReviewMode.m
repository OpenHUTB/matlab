


function toggleAutomaticReviewMode(cbinfo,~)

    studio=cbinfo.studio;


    mm=slci.manualreview.Manager.getInstance;
    mm.close(studio);


    customContext=slci.toolstrip.util.getSlciAppContext(studio);
    customContext.setAutomaticReviewMode();


    if~isempty(customContext)
        customContext.updateAutomaticReviewTypeChain();
    end
