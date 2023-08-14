function convertAllSubsystemReferenceBlocksToSubsystem(input)






    handle=get_param(input,'Handle');
    if(strcmp(get_param(handle,'Type'),'block_diagram'))
        slInternal('convertAllSSRefBlocksToSubsystemBlocks',handle);
    else
        error(message('Simulink:SubsystemReference:InputMustBeBD'));
    end
end