function convertSubsystemReferenceBlockToSubsystem(input)




    handle=get_param(input,'Handle');
    slInternal('convertSSRefBlockToSubsystemBlock',handle);
end