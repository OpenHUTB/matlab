


function toggleReportView(cbinfo,~)

    studio=cbinfo.studio;

    vm_studio=slci.view.Studio.getFromStudio(studio);

    if~isempty(vm_studio)
        vm_report=vm_studio.getReport();


        vm_report.turnOn();

        vm_report.refresh();
    end