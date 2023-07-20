function setPackageDirty(artifact)

    [~,artifactName,type]=fileparts(artifact);

    switch type

    case '.slx'
        Simulink.slx.setPartDirty(artifactName,'SlreqLinkset')




    otherwise

    end

end