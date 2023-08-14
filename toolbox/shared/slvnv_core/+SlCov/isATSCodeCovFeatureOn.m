



function status=isATSCodeCovFeatureOn()

    persistent hasCoderConnectivity
    if isempty(hasCoderConnectivity)
        hasCoderConnectivity=exist('coder.connectivity.XILSubsystemUtils','class')==8;
    end

    status=hasCoderConnectivity&&...
    coder.internal.connectivity.featureOn('SILPILAtomicSubsystem')&&...
    codeinstrumprivate('feature','enableATSCodeCoverage');
