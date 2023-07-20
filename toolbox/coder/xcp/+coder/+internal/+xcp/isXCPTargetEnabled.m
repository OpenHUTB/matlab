function ret=isXCPTargetEnabled()




    ret=coder.internal.connectivity.featureOn('XcpTargetConnection')&&...
    coder.internal.connectivity.featureOn('XcpCoderTarget');

end