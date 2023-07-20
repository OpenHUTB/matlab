
function toggleReqsBrowser(cbinfo)



    modelH=slreq.toolstrip.getModelHandle(cbinfo);

    appmgr=slreq.app.MainManager.getInstance();

    spObj=appmgr.spreadsheetManager.getSpreadSheetObject(modelH);

    if isempty(spObj)

        return;
    end


    showPI=isVisiblePI(modelH);
    if~spObj.isComponentVisible
        spObj.show(cbinfo.studio,showPI);
    else
        spObj.hideBrowser();
    end
end


function out=isVisiblePI(modelH)
    editor=rmisl.modelEditors(bdroot(modelH),true);
    studio=editor.getStudio;
    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    out=pi.isVisible;
end