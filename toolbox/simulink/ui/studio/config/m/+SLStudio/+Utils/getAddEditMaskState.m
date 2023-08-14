function state=getAddEditMaskState(cbinfo)






    if Simulink.internal.isParentArchitectureDomain(cbinfo)
        state='Disabled';
    else
        enabled=SLStudio.Utils.callBoolMethodOnDomian(cbinfo,'isCreateEditMaskEnabled');

        if enabled
            state='Enabled';
            aSelectedItem=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if~isempty(aSelectedItem)
                aBlockHdl=aSelectedItem.handle;
                if Simulink.harness.internal.isPartOfActiveHarnessLockedCUT(aBlockHdl)
                    state='Disabled';
                end
            end
        else
            state='Disabled';
        end
    end
end
