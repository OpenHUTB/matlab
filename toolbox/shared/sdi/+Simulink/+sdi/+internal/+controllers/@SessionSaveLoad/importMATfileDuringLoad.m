function importMATfileDuringLoad(this,fullFileName,isAppending,choice)


    this.ActionInProgress=false;


    if choice~=0
        return
    end



    if~isAppending
        Simulink.sdi.clear(true);
    end


    ctrlObj=Simulink.sdi.internal.controllers.ImportDialog.getController();
    ctrlObj.Model.baseWSOrMAT=false;
    ctrlObj.Model.matFileName=fullFileName;

    ctrlObj.Dispatcher.publish(...
    ctrlObj.ControllerID,'launchGUI',fullFileName);
end
