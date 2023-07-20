






function dlg=createSlicerDialog(obj)
    modelH=get_param(obj.model,'Handle');

    set_param(obj.model,'FastRestart','on');


    dlg=createSlicerDDG(modelH);




    if~isempty(dlg)
        dlgSrc=dlg.getDialogSource;
        dlgSrc.Model.modelSlicer.addlistener('eventModelSlicerDialogClosed',...
        @(~,~)obj.revertModelToOriginalState);
        obj.disableCriteriaPanel(dlg);




        if strcmp(get_param(obj.model,'FastRestart'),'off')
            obj.isFastRestartSupported=false;
        end
    end


    if isempty(dlg)||dlg.getDialogSource.Model.modelSlicer.hasError

        dlg=[];
        return;
    end
end
