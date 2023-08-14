
function newReqSet(cbinfo)

    appmgr=slreq.app.MainManager.getInstance();

    reqSetDas=appmgr.callbackHandler.addNewReqSet();


    if~isempty(reqSetDas)
        if slreq.toolstrip.activateEditor(cbinfo)
            appmgr.requirementsEditor.setSelectedObject(reqSetDas);
        else

            modelH=slreq.toolstrip.getModelHandle(cbinfo);

            currentView=appmgr.getSpreadSheetObject(modelH);
            if isa(currentView,'slreq.gui.ReqSpreadSheet')
                currentView.createAndRegisterLinkSet(reqSetDas);
            end
            currentView.setSelectedObject(reqSetDas);
        end
        appmgr.update();
    end

end