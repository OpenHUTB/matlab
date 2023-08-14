function retVal=blockShouldNotHavePriority(block)




    retVal=false;
    blkType=get_param(block,'BlockType');
    if strcmp(blkType,'Merge')
        retVal=true;


    elseif strcmp(blkType,'SubSystem')
        ssType=Simulink.SubsystemType(block);

        if ssType.isFunctionCallSubsystem()||...
            ssType.isActionSubsystem()||...
            ssType.isInitTermOrResetSubsystem()
            retVal=true;
        end
    end

end

