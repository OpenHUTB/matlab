function toggleSigScopeMgrCB(userdata,cbinfo)
    toggle=cbinfo.EventData;
    studio=cbinfo.studio;
    tab=0;
    if strcmpi(userdata,'generators')
        tab=1;
    end
    mdlHandle=cbinfo.editorModel.Handle;
    if toggle
        selected=0;
        obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidSigGenPort(obj)
            selected=SLStudio.Utils.getSigGenSourceBlock(obj);
        end
        sigandscopemgr('GetLibraries');
        Simulink.scopes.SigScopeMgr.showSigScopeMgr(cbinfo,selected);

        [ssmComponent,~]=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio);
        dlg=ssmComponent.getDialog();
        dlg.setActiveTab('viewersAndGenerators',tab);
    else
        ssmComponent=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio,cbinfo.editorModel.name,1);
        if~isempty(ssmComponent)
            studio.hideComponent(ssmComponent);
        end
    end
end