



function showPropertyInspectorCB(cbinfo)

    studio=cbinfo.studio;
    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    if~pi.isVisible
        studio.showComponent(pi);
    else
        studio.hideComponent(pi);
    end
end
