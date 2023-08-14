function chooseSource(hThis,dlg)




    if lCheckUnappliedChanges(dlg)
        hSource=hThis.getDlgSrcObj;
        hSource.RequestChooser=true;
        hSource.BuilderObj=[];
    end

end

function result=lCheckUnappliedChanges(dlg)






    dlg.clearWidgetDirtyFlag('ViewSource');


    if dlg.hasUnappliedChanges
        choices={'Yes','No','Cancel','Yes'};
        msg=getString(...
        message('physmod:ne_sli:dialog:ApplyParametersDialogString'));
        dlgTitle=getString(...
        message('physmod:ne_sli:dialog:UnappliedChangesDialogTitle'));

        userChoice=questdlg(msg,dlgTitle,choices{:});
        if strcmp(userChoice,choices{2})
            result=true;
        elseif strcmp(userChoice,choices{1})
            dlg.apply();
            result=true;
        else
            result=false;
        end
    else
        result=true;
    end
end
