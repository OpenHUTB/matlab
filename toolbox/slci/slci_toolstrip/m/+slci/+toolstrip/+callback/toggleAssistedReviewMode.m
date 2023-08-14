


function toggleAssistedReviewMode(cbinfo,~)

    studio=cbinfo.studio;


    vm=slci.view.Manager.getInstance;
    vm.close(studio);


    customContext=slci.toolstrip.util.getSlciAppContext(studio);
    customContext.setAssistedReviewMode();


    if~isempty(customContext)
        customContext.updateAssistedReviewTypeChain();
    end
