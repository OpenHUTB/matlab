function showCodeMapping(userdata,cbinfo)





    studio=cbinfo.studio;


    editor=studio.App.getActiveEditor;
    bdh=editor.blockDiagramHandle;
    simulinkcoder.internal.util.openCodeMappingSS(studio,bdh);


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    appName=cp.getInfo(bdh);
    if strcmp(appName,'DDS')
        pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
        if pi.isVisible
            studio.showComponent(pi);
            pi.restore;
        end
    end

    ss=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
    studio.showComponent(ss);
    ss.restore;
    studio.focusComponent(ss);

    isFcnPlatform=coder.internal.toolstrip.util.getPlatformType(cbinfo.model.handle);






    if~isFcnPlatform


        tab=str2double(userdata);
        ss.setCurrentTab(tab);
    end


