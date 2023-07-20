function toggleXCPfeatures(state)




    mlock;

    if~(strcmp(state,'on')||strcmp(state,'off'))
        return;
    end

    persistent XCPState oldSLCGDirectEmitSerialize oldXcpTargetConnection oldXcpCoderTarget;

    if(isempty(XCPState)&&strcmp(state,'off'))
        return;
    elseif isempty(XCPState)
        oldSLCGDirectEmitSerialize=slsvTestingHook('SerializeAllTAQSrcBlocksToCodeDescriptor');
        oldXcpTargetConnection=coder.internal.connectivity.featureOn('XcpTargetConnection');
        oldXcpCoderTarget=coder.internal.connectivity.featureOn('XcpCoderTarget');
    end





    XCPState=state;





    switch state
    case 'on'
        slsvTestingHook('SerializeAllTAQSrcBlocksToCodeDescriptor',1);
        coder.internal.connectivity.featureOn('XcpTargetConnection',true);
        coder.internal.connectivity.featureOn('XcpCoderTarget',true);
    case 'off'
        slsvTestingHook('SerializeAllTAQSrcBlocksToCodeDescriptor',oldSLCGDirectEmitSerialize);
        coder.internal.connectivity.featureOn('XcpTargetConnection',oldXcpTargetConnection);
        coder.internal.connectivity.featureOn('XcpCoderTarget',oldXcpCoderTarget);
    end


















end

