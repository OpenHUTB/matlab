


function toggleResultReview(cbinfo,~)

    studio=cbinfo.studio;


    vm_studio=slci.view.Studio.getFromStudio(studio);
    if~isempty(vm_studio)
        vm_result=vm_studio.getResultReview();

        try

            slci.Configuration.checkWorkDir;


            vm_result.refresh();
        catch ME
            slci.internal.outputMessage(ME,'error');
            return;
        end


        vm_result.turnOn();

    end
