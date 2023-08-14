function peripheralBlkCopyFcn(type,blkH)






    mdl=codertarget.utils.getModelForBlock(blkH);
    hCS=getActiveConfigSet(mdl);
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end

    defFile=codertarget.peripherals.utils.getDefFileNameForBoard(hCS);


    appMdl=codertarget.peripherals.AppModel(mdl,defFile);

    if codertarget.peripherals.AppModel.isProcessorModel(bdroot(blkH))



        if loc_canPeripheralInfoBeCopied(blkH)


            appMdl.copyPeripheralInfo(blkH,type);
        else

            appMdl.addDefaultPeripheralInfo(blkH,type);
        end
    end


    set_param(blkH,'BlockSID',Simulink.ID.getSID(blkH));

end

function out=loc_canPeripheralInfoBeCopied(blkH)




    blkSID=get_param(blkH,'BlockSID');

    srcMdl=bdroot(blkSID);

    destMdl=bdroot(blkH);



    if~(codertarget.targethardware.arePeripheralsSupported(getActiveConfigSet(srcMdl))&&...
        codertarget.targethardware.arePeripheralsSupported(getActiveConfigSet(destMdl)))
        out=false;
    else

        hasSavedPeriphInfo=loc_isPeripheralInfoInParentModel(blkSID);




        hasCompatiblePeriphInfo=loc_doesHardwareMatch(srcMdl,destMdl);

        out=hasCompatiblePeriphInfo&&hasSavedPeriphInfo;
    end
end

function out=loc_doesHardwareMatch(model1,model2)


    if matches(get_param(model1,'HardwareBoard'),...
        get_param(model2,'HardwareBoard'))
        out=true;
    else
        out=false;
    end
end

function out=loc_isPeripheralInfoInParentModel(blkH)



    out=false;
    id=Simulink.ID.getSID(blkH);
    hCS=getActiveConfigSet(bdroot(id));
    pInfo=codertarget.data.getPeripheralInfo(hCS);

    if~isempty(pInfo)
        types=fieldnames(pInfo);
        for i=1:numel(types)
            idx=find(strcmp({pInfo.(types{i}).Block.ID},id),1);
            if~isempty(idx)
                out=true;
                break;
            end
        end
    end
end


