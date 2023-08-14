




function stateflowContainerRF(cbinfo,action)
    action.enabled=false;
    if~SLStudio.Utils.isLockedSystem(cbinfo)
        editor=cbinfo.studio.App.getActiveEditor;
        SFStudio.Utils.sfMarqueeActionUtils.requireEditor(editor,'Stateflow:studio:SFCreateSubchart');
        action.enabled=StateflowDI.Util.canCreateBoxAroundSelection(editor,[0,0,0,0]);
    end
end
