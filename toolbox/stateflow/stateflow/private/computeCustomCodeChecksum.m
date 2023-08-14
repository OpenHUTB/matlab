function chkSum=computeCustomCodeChecksum(chkSum,targetId,parentTargetId)





    customCodeSettings=sfc('private','get_custom_code_settings',targetId,parentTargetId);

    chkSum=CGXE.Utils.md5(chkSum...
    ,feature('CGForceUnsignedConsts')...
    );





    chkSum=customCodeSettings.fieldChecksum(chkSum);

    if customCodeSettings.hasSettings


        chkSum=CGXE.Utils.md5(chkSum,customCodeSettings.parseCC);
    end
