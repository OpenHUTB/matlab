function state=getWizardMenuState(cbinfo,fromContextMenu)

    isSimulinkFunctionBlock=false;
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    isSubsystem=SLStudio.Utils.objectIsValidSubsystemBlock(block);
    isBlock=SLStudio.Utils.objectIsValidBlock(block);
    state='Hidden';
    if~(dig.isProductInstalled('Embedded Coder')&&...
        simulinkcoder.internal.wizard.Wizard.isFeatureOn)
        return;
    end
    if isBlock
        if isSubsystem
            isSimulinkFunctionBlock=strcmp(get_param(block.handle,'SystemType'),'SimulinkFunction');
        end
        if(isSimulinkFunctionBlock)
            state='Disabled';
        elseif isSubsystem
            state='Enabled';
        else
            if fromContextMenu
                state='Hidden';
            else

                state='Enabled';
            end
        end
    else
        if~fromContextMenu
            state='Enabled';
        end
    end

end