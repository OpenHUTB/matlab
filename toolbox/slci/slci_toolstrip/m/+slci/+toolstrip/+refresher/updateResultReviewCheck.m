


function updateResultReviewCheck(cbinfo,action)

    st=cbinfo.studio;

    vm=slci.view.Studio.getFromStudio(st);
    comp=vm.getResultReview();

    action.selected=comp.getStatus;