function tf=isInlineSoftwareComponentBlock(blockHandle)





    tf=strcmpi(get_param(blockHandle,'type'),'block')&&...
    strcmpi(get_param(blockHandle,'BlockType'),'SubSystem')&&...
    (strcmpi(get_param(blockHandle,'SimulinkSubDomain'),'SoftwareArchitecture')||...
    strcmpi(get_param(blockHandle,'SimulinkSubDomain'),'AUTOSARArchitecture'));
end
