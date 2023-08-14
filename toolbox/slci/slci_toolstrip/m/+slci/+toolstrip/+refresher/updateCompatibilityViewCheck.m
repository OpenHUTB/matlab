


function updateCompatibilityViewCheck(cbinfo,action)

    st=cbinfo.studio;

    vm=slci.view.Studio.getFromStudio(st);
    comp=vm.getCompatibility();

    action.selected=comp.getStatus;