function getCompReport(userdata,cbinfo)

    if~strcmp(userdata,'get_report')
        return;
    end




    objectId=slmle.internal.getObjectId(cbinfo);
    blkH=slmle.internal.getBlockHandleFromObjectId(objectId);
    cid=slmle.internal.object2Data(objectId,'getChartId');


    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    editor=m.getMLFBEditorByStudioAdapter(saEd);

    if(isempty(editor))
        error('Not a valid MLFBEditor object')
    end

    if strcmp(editor.type,'EMFunction')

        blkH=0;
    end

    sfprivate('eml_report_manager','open',cid,blkH);