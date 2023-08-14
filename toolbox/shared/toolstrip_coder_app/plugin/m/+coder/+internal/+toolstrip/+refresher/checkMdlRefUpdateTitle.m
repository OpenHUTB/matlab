function checkMdlRefUpdateTitle(cbinfo,action)









    if coderdictionary.data.feature.getFeature('CodeGenIntent')==0
        studio=cbinfo.studio;
        [status,~]=simulinkcoder.internal.util.getCodeMappingPanelStatus(studio);
        action.enabled=status==2;
    end

    if slfeature('DeploymentTypeInCMapping')>0
        modelH=cbinfo.model.handle;
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        app=cp.getInfo(modelH);
        mapping=Simulink.CodeMapping.getCurrentMapping(modelH);
        if strcmp(app,'EmbeddedCoder')&&~isempty(mapping)
            if~mapping.isFunctionPlatform
                action.text='ToolstripCoderApp:toolstrip:IndividualMappingText';
            else
                if isequal(mapping.DeploymentType,'Component')
                    action.text='ToolstripCoderApp:toolstrip:IndividualMappingComponentText';
                elseif isequal(mapping.DeploymentType,'Subcomponent')
                    action.text='ToolstripCoderApp:toolstrip:IndividualMappingSubcomponentText';
                end
            end
        end
    end


