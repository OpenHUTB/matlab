


function toggleJustificationView(cbinfo,~)

    studio=cbinfo.studio;


    vm_studio=slci.view.Studio.getFromStudio(studio);

    if~isempty(vm_studio)
        vm_justification=vm_studio.getJustification();


        vm_justification.turnOn();
    end