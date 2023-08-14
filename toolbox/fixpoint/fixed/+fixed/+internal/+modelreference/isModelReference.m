function isMdlRef=isModelReference(modelBlockID)
















    try
        sid=Simulink.ID.getSID(modelBlockID);
        blockType=get_param(sid,'BlockType');
        isMdlRef=strcmp(blockType,'ModelReference');
    catch
        isMdlRef=false;
    end
end