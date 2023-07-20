


function updateReportViewCheck(cbinfo,action)

    st=cbinfo.studio;

    vm=slci.view.Studio.getFromStudio(st);
    comp=vm.getReport();

    action.selected=comp.getStatus;