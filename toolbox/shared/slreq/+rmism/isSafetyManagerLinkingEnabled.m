
function tf=isSafetyManagerLinkingEnabled()
    tf=logical(reqmgt('rmiFeature','SafetyManagerLinking'));
end