function hardwareBoardFeatureSetChanged(hCS)





    attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
    if~isempty(attributeInfo)











        if isequal(get_param(hCS,'HardwareBoard'),...
            codertarget.data.getParameterValue(hCS,'TargetHardware'))

            if~isempty(attributeInfo.getOnHardwareDeselectHook)
                feval(attributeInfo.getOnHardwareDeselectHook,hCS);
            end


            codertarget.attributes.resetExtModeData(hCS);
            codertarget.data.initializeTargetData(hCS);
            targetHardwareInfo=codertarget.targethardware.getTargetHardware(hCS);
            codertarget.target.initializeTarget(hCS,targetHardwareInfo);


            if~isempty(attributeInfo.getOnHardwareSelectHook)
                feval(attributeInfo.getOnHardwareSelectHook,hCS);
            end


            fsValue=get_param(hCS,'HardwareBoardFeatureSet');
            codertarget.utils.setESBPluginAttached(hCS,isequal(fsValue,'SoCBlockset'));
        end
    end
end