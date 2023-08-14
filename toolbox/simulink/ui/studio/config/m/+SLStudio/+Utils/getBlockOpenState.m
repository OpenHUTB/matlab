function state=getBlockOpenState(cbinfo,allow_masked)




    state='Hidden';
    [target,targethid]=SLStudio.Utils.getTargetInfo(cbinfo);

    if~GLUE2.HierarchyService.isValid(targethid)&&~target.isvalid
        return
    end
    if~target.isvalid
        scopedTarget=GLUE2.HierarchyService.getM3IObject(targethid);
        target=scopedTarget.temporaryObject();
    end
    if isa(target,'SLM3I.Diagram')



        hidToOpen=cbinfo.targetHID;
        if SLStudio.Utils.isHIDOpenInCurrentTab(cbinfo.studio,hidToOpen)
            state='Disabled';
        else
            state='Enabled';
        end
    else
        if target.isConfigurableSubsystem&&~target.isConfigurableSubsystemInstance
            state='Enabled';
            return
        end
        [hidToOpen,objToOpen]=SLStudio.Utils.getHIDAndObjToOpen(cbinfo);

        if isempty(objToOpen)
            state='Disabled';
        elseif isa(objToOpen,'Simulink.SubSystem')&&SLStudio.Utils.isHIDOpenInCurrentTab(cbinfo.studio,hidToOpen)
            state='Disabled';
        elseif~allow_masked&&~isempty(get_param(objToOpen.handle,'OpenFcn'))

            state='Enabled';
        elseif strcmpi(objToOpen.BlockType,'SubSystem')&&strcmpi(objToOpen.Permissions,'NoReadOrWrite')



            state='Disabled';
        elseif strcmpi(objToOpen.BlockType,'Scope')

            state='Enabled';
        elseif isa(objToOpen,'Simulink.SubSystem')&&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'None')&&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'Chart')
            state='Enabled';
        elseif GLUE2.HierarchyService.isValid(hidToOpen)



            if~objToOpen.isModelReference&&(allow_masked||~SLStudio.Utils.isMaskedSubsystemBlock(objToOpen))
                if SLStudio.Utils.isHIDOpenInCurrentTab(cbinfo.studio,hidToOpen)
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
