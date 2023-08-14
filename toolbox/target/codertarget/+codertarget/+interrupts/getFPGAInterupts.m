function[totalInterrupts,interruptsInfo]=getFPGAInterupts(hCS)




    boardName=codertarget.data.getParameterValue(hCS,'TargetHardware');

    hwInfo=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(hwInfo)
        if isequal(hwInfo(i).Name,boardName)
            tgtFolder=hwInfo(i).TargetFolder;
            [~,fileName]=fileparts(hwInfo(i).DefinitionFileName);
            break;
        end
    end
    xmlFilePath=fullfile(tgtFolder,'registry','interrupts',[fileName,'FPGAInterrupts.xml']);
    if isfile(xmlFilePath)

        intrObj=codertarget.interrupts.FPGAInterruptsInfo(xmlFilePath);
        totalInterrupts=intrObj.TotalNumInterrupts;
        interruptsInfo=intrObj.FPGAInterrupts;
    else

        cstmBrdParams=soc.internal.getCustomBoardParams(boardName);
        devFamily=cstmBrdParams.fdevObj.FPGAFamily;
        if any(strcmpi(devFamily,{'MPSoC','RFSoC'}))
            psParams=cstmBrdParams.fdesObj.CustomDesignTclHooks.ProcessingSystem;
            psParamsMap=containers.Map(psParams(1:2:end),psParams(2:2:end));
            interfaceNames=psParamsMap('InterruptInterface');
            if~iscell(interfaceNames)
                numInterfaces=1;
            else
                numInterfaces=numel(interfaceNames);
            end
            totalInterrupts=8*numInterfaces;
            interruptsInfo=[];
        else
            totalInterrupts=16;
            interruptsInfo=[];
        end
    end
end