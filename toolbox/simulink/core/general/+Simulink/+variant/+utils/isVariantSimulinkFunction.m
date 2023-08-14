function[flag,trigPortBlockH]=isVariantSimulinkFunction(blockH)









    trigPortBlockH=[];

    if~ishandle(blockH)
        blockH=get_param(blockH,'Handle');
    end

    flag=slInternal('isSimulinkFunction',blockH);

    if~flag
        return;
    end




    persistent findOpts;
    if isempty(findOpts)
        findOpts=Simulink.FindOptions('IncludeCommented',false,'SearchDepth',1,'LookInsideSubsystemReference',true);
    end

    trigPortBlockH=Simulink.findBlocksOfType(blockH,'TriggerPort',findOpts);


    flag=~isempty(trigPortBlockH)&&any(strcmp(get_param(trigPortBlockH,'Variant'),'on'));

    if~flag
        trigPortBlockH=[];
    end

end


