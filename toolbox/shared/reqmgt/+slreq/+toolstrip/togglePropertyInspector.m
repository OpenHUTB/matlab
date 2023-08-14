
function togglePropertyInspector(cbinfo)



    modelH=slreq.toolstrip.getModelHandle(cbinfo);

    editor=rmisl.modelEditors(bdroot(modelH),true);
    studio=editor.getStudio;
    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');

    if~pi.isVisible
        studio.showComponent(pi);
        mgr=slreq.app.MainManager.getInstance;
        view=mgr.getCurrentView;


        if~isempty(view)&&isvalid(view)
            currentObj=view.getCurrentSelection();
            if~isempty(currentObj)
                pi.updateSource('GLUE2:PropertyInspector',currentObj);
            end
        end
    else
        studio.hideComponent(pi);
    end
end