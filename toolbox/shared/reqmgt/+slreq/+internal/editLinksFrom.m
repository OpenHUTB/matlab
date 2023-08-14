function editLinksFrom(srcDomain,srcArtifact,srcId,linkIdx)













    switch srcDomain
    case 'linktype_rmi_matlab'
        rmiml.editLinks(srcArtifact,srcId,linkIdx);
    case 'linktype_rmi_simulink'
        [~,mdlName]=fileparts(srcArtifact);
        obj=Simulink.ID.getHandle([mdlName,srcId]);
        rmi.editReqs(obj,linkIdx);
    otherwise
        srcIdString=[srcArtifact,'|',srcId];
        rmi.editReqs(srcIdString,linkIdx);
    end
end
