






function dlgSrc=setupSlicerDialog(obj)

    modelH=get_param(obj.model,'Handle');
    msObj=modelslicerprivate('slicerMapper','get',modelH);

    if isa(msObj,'ModelSlicer')&&~isempty(msObj.dlg)
        dlg=msObj.dlg;
    else

        dlg=obj.createSlicerDialog();
    end
    if isempty(dlg)
        dlgSrc=[];
        return;
    end
    dlgSrc=dlg.getDialogSource;

end
