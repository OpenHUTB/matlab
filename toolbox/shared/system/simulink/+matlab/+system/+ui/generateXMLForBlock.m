function sysXMLFilePath=generateXMLForBlock(blkHdl)





    bIsMasked=strcmp(get_param(blkHdl,'Mask'),'on');
    if bIsMasked&&strcmp(get_param(blkHdl,'BlockType'),'MATLABSystem')
        maskObj=Simulink.Mask.get(blkHdl);
        Sys=get_param(blkHdl,'System');
        sysFilePath=which(Sys);
        if isempty(maskObj.BaseMask)
            TriggerAuxXMLCreationBySavingTempSysObjectModel();
            sysXMLFilePath=[sysFilePath(1:end-2),'.xml'];
        end
    end



    function TriggerAuxXMLCreationBySavingTempSysObjectModel()
        mdl=qeTempMdl;
        open_system(new_system(mdl));
        blk=add_block('built-in/MATLABSystem',[mdl,'/(preview)']);
        set_param(blk,'System',Sys);
        mdlFullPath=[tempdir,mdl,qeModelExtension.defaultModelExtension];



        save_system(mdlFullPath);
        close_system(mdlFullPath,false);
    end
end