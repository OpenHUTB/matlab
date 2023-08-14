function fixedPoint(userdata,cbinfo)




    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=m.getMLFBEditorByStudioAdapter(saEd);


    persistent fiDialog;
    persistent ntDialog;
    persistent fimathDialog;

    switch userdata



    case 'insert_fi'
        if isempty(fiDialog)||~isvalid(fiDialog)
            fiDialog=fixed.dialog.fiDialog(ed);
        else
            figure(fiDialog);
        end
    case 'insert_numericType'
        if isempty(ntDialog)||~isvalid(ntDialog)
            ntDialog=fixed.dialog.ntDialog(ed);
        else
            figure(ntDialog);
        end
    case 'insert_fiMath'
        if isempty(fimathDialog)||~isvalid(fimathDialog)
            fimathDialog=fixed.dialog.fimathDialog(ed);
        else
            figure(fimathDialog);
        end
    end