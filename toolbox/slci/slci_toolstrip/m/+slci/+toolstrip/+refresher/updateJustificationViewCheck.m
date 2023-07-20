


function updateJustificationViewCheck(cbinfo,action)

    st=cbinfo.studio;

    vm=slci.view.Studio.getFromStudio(st);
    comp=vm.getJustification();

    action.selected=comp.getStatus;