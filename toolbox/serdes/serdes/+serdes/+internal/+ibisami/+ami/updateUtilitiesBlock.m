








function updateUtilitiesBlock(utilitiesBlockName,updateType)

    targetBlock=find_system(serdes.utilities.modelRoot,'SearchDepth',1,'BlockType','SubSystem','Name',utilitiesBlockName);

    if isempty(targetBlock)||size(targetBlock,1)>1
        return
    end

    block=targetBlock{1};

    model=bdroot(block);
    mws=get_param(model,'ModelWorkspace');

    simStatus=get_param(model,'SimulationStatus');
    if strcmp(simStatus,'stopped')&&~isempty(mws)
        maskObj=Simulink.Mask.get(block);
        if~isempty(maskObj)
            if strcmp(updateType,'IgnoreBitsDisplay')

                ignoreBits=serdes.internal.callbacks.getIgnoreBits(mws);
                maskNames={maskObj.Parameters.Name};
                maskObj.Parameters(strcmp(maskNames,'IgnoreBitsDisplay')).Value=num2str(ignoreBits);


                hasIgnoreBits=mws.hasVariable('IgnoreBits');
                if hasIgnoreBits
                    tempIgnoreBits=mws.getVariable('IgnoreBits');
                else
                    tempIgnoreBits=0;
                end

                if~hasIgnoreBits||tempIgnoreBits~=ignoreBits
                    mws.assignin('IgnoreBits',ignoreBits);
                end


                serdes.internal.callbacks.maskApply(block);
            elseif strcmp(updateType,'Jitter')
                serdes.internal.callbacks.stimulusUpdate(block,"Initialization")
            end
        end
    end
end

