function checkMdlRef(cbinfo,action)

    if coderdictionary.data.feature.getFeature('CodeGenIntent')==0

        studio=cbinfo.studio;
        [status,~]=simulinkcoder.internal.util.getCodeMappingPanelStatus(studio);

        action.enabled=status==2;
    end



