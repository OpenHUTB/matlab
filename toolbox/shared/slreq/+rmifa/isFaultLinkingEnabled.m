function tf=isFaultLinkingEnabled()

    tf=logical(reqmgt('rmiFeature','FaultLinking'));
end