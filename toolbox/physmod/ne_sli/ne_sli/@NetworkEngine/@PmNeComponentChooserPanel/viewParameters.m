function viewParameters(hThis,dlg)











    dlg.clearWidgetDirtyFlag('ViewSource');


    hSource=hThis.getDlgSrcObj;
    refreshDialogSchema=true;


    notPreviouslySpecified=isempty(hThis.BlockHandle.SourceFile);
    if notPreviouslySpecified&&isempty(hThis.ComponentName)
        lNotSpecifiedError()
        return
    end

    currentComp=simscape.getBlockComponent(hThis.BlockHandle.handle());
    specifiedComp=dlg.getWidgetValue('ComponentName');
    componentChanged=~strcmp(specifiedComp,currentComp);





    if componentChanged&&dlg.hasUnappliedChanges


        if notPreviouslySpecified
            choices={'Yes','Cancel','Yes'};
        else
            choices={'Yes','No','Cancel','Yes'};
        end

        msg=getString(...
        message('physmod:ne_sli:dialog:ApplyComponentDialogString'));
        dlgTitle=getString(...
        message('physmod:ne_sli:dialog:UnappliedChangesDialogTitle'));

        result=questdlg(msg,dlgTitle,choices{:});

        if strcmp(result,'Yes')
            dlg.apply();
            refreshDialogSchema=false;
        elseif strcmp(result,'No')



            hSource.ComponentName=currentComp;
            dlg.setWidgetValue('ComponentName',hSource.ComponentName);
            refreshDialogSchema=true;
            dlg.clearWidgetDirtyFlag('ComponentName');
        else
            refreshDialogSchema=false;
        end
    end


    if refreshDialogSchema
        hSource.RequestChooser=false;
        hSource.BuilderObj=[];
        dlg.refresh();
    else
        dlg.refresh();
    end

end

function lNotSpecifiedError()
    msgString=getString(...
    message('physmod:ne_sli:dialog:SimscapeComponentUnspecified'));
    titleString=getString(...
    message('physmod:ne_sli:dialog:SimscapeComponentUnspecifiedTitle'));
    errordlg(msgString,titleString,'modal');
end
