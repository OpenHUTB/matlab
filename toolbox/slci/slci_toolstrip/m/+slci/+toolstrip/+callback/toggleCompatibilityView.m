


function toggleCompatibilityView(cbinfo,~)

    studio=cbinfo.studio;


    vm_studio=slci.view.Studio.getFromStudio(studio);
    if~isempty(vm_studio)
        vm_compatibility=vm_studio.getCompatibility();


        vm_compatibility.refresh();


        vm_compatibility.show();

    end

