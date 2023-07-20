function state=getModelReferenceOpenState(cbinfo,allow_masked,openType)




    state='Hidden';
    targethid=cbinfo.targetHID;
    target=cbinfo.target;
    if~GLUE2.HierarchyService.isValid(targethid)&&~target.isvalid
        return
    end
    if~target.isvalid
        scopedTarget=GLUE2.HierarchyService.getM3IObject(targethid);
        target=scopedTarget.temporaryObject();
    end
    if~isa(target,'SLM3I.Diagram')

        if target.isConfigurableSubsystem&&~target.isConfigurableSubsystemInstance
            state='Hidden';
            return
        end
        [hidToOpen,objToOpen]=SLStudio.Utils.getHIDAndObjToOpen(cbinfo);
        if isempty(objToOpen)
            state='Hidden';
        elseif objToOpen.isModelReference&&(allow_masked||~(hasmask(objToOpen.Handle)&&hasmaskdlg(objToOpen.Handle)))&&SLStudio.Utils.isSubSystemUnprotectedModelReference(objToOpen)
            switch openType
            case 'TAB'
                if SLStudio.Utils.isHIDOpenInAnyTab(cbinfo.studio,hidToOpen)
                    state='Disabled';
                else
                    state='Enabled';
                end
            case 'WINDOW'
                state='Enabled';
            case 'TOP'
                state='Enabled';
            otherwise
                if GLUE2.HierarchyService.isValid(hidToOpen)&&SLStudio.Utils.isHIDOpenInCurrentTab(cbinfo.studio,hidToOpen)
                    state='Disabled';
                else
                    state='Enabled';
                end
            end
        end
    end


    if strcmp(state,'Enabled')
        tree=cbinfo.studio.getComponent('GLUE2 tree component','GLUE2 tree component');
        if~isempty(tree)&&tree.hasSpotlightView()
            state='Disabled';
        end
    end

end
