function saveGlobalSettings(this,treeNode,batchName)





    mdlSettingMap=this.getGlobalSettingMapForShortcut(batchName);

    for m={'DAObject','CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
        param=m{:};
        switch param
        case 'DAObject'
            mdlSettingMap.insert(param,treeNode);
            mdlSettingMap.insert('SID',Simulink.ID.getSID(treeNode));
        otherwise
            mdlSettingMap.insert(param,true)
            mdlSettingMap.insert('RunName',get_param(this.ModelName,'FPTRunName'));
        end
    end
end
