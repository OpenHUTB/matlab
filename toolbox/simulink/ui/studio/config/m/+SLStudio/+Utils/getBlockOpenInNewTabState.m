function state=getBlockOpenInNewTabState(cbinfo,allow_masked)




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
    if isa(target,'SLM3I.Diagram')



        hidToOpen=cbinfo.targetHID;
        if SLStudio.Utils.isHIDOpenInAnyTab(cbinfo.studio,hidToOpen)
            state='Disabled';
        else
            state='Enabled';
        end
    else

        if target.isConfigurableSubsystem&&~target.isConfigurableSubsystemInstance
            state='Hidden';
            return
        end
        [hidToOpen,objToOpen]=SLStudio.Utils.getHIDAndObjToOpen(cbinfo);

        if isempty(objToOpen)


            state='Disabled';
        elseif isa(objToOpen,'Simulink.SubSystem')&&SLStudio.Utils.isHIDOpenInAnyTab(cbinfo.studio,hidToOpen)


            state='Disabled';
        elseif strcmpi(objToOpen.BlockType,'SubSystem')&&strcmpi(objToOpen.Permissions,'NoReadOrWrite')



            state='Disabled';
        elseif isa(objToOpen,'Simulink.SubSystem')&&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'None')...
            &&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'Chart')...
            &&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'State Transition Table')...
            &&~strcmpi(get_param(objToOpen.Handle,'SFBlockType'),'Truth Table')

            if feature('openMLFBInSimulink')
                studioAdapterBlocktype=SA_M3I.StudioAdapterToolstripRegistryInterface.getStudioAdapterType(objToOpen.Handle);
                isStudioAdapter=SA_M3I.StudioAdapterToolstripRegistryInterface.isStudioAdapterTypeRegistered(studioAdapterBlocktype);
                if isStudioAdapter
                    state='Enabled';
                else
                    state='Hidden';
                end
            else
                state='Hidden';
            end
        elseif GLUE2.HierarchyService.isValid(hidToOpen)



            if~objToOpen.isModelReference&&(allow_masked||~SLStudio.Utils.isMaskedSubsystemBlock(objToOpen))
                if SLStudio.Utils.isHIDOpenInAnyTab(cbinfo.studio,hidToOpen)
                    state='Disabled';
                else
                    state='Enabled';
                end
            end
        end
        if~allow_masked&&SLStudio.Utils.targetHasOpenCB(target)&&strcmpi(state,'Enabled')
            state='Disabled';
        end
    end


    if strcmp(state,'Enabled')
        tree=cbinfo.studio.getComponent('GLUE2 tree component','GLUE2 tree component');
        if~isempty(tree)&&tree.hasSpotlightView()
            state='Disabled';
        end
    end

end
