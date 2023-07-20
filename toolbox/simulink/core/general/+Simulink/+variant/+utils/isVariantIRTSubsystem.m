function[flag,eventListenerBlkH]=isVariantIRTSubsystem(blockH)









    eventListenerBlkH=[];

    if~ishandle(blockH)
        blockH=get_param(blockH,'Handle');
    end

    flag=slInternal('isInitTermOrResetSubsystem',blockH);

    if~flag
        return;
    end


    persistent findOpts;
    if isempty(findOpts)
        findOpts=Simulink.FindOptions('IncludeCommented',false,'SearchDepth',1,'LookInsideSubsystemReference',true);
    end

    eventListenerBlkH=Simulink.findBlocksOfType(blockH,'EventListener',findOpts);


    flag=~isempty(eventListenerBlkH)&&any(strcmp(get_param(eventListenerBlkH,'Variant'),'on'));

    if~flag
        eventListenerBlkH=[];
    end
end


