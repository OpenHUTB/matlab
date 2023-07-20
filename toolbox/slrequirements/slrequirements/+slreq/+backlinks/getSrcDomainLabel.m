function mwDomain=getSrcDomainLabel(mwSourceArtifact)









    [~,~,mwExt]=fileparts(mwSourceArtifact);

    if rmiut.isSimulinkArtifact(mwSourceArtifact,mwExt)
        mwDomain='linktype_rmi_simulink';
    else
        shortLabel=rmiut.resolveType(mwSourceArtifact);
        mwDomain=['linktype_rmi_',shortLabel];
    end

end
