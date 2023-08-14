function[domain,artifactName]=getDomainLabel(artifactPath)

    [aPath,artifactName,aExt]=fileparts(artifactPath);

    if isempty(aExt)&&isempty(aPath)

        if exist(artifactName,'file')==4
            domain='linktype_rmi_simulink';
        else
            fromWhich=which(artifactName);
            if isempty(fromWhich)
                domain='';
            else
                domain=slreq.utils.getDomainLabel(fromWhich);
            end
        end
    else
        switch aExt
        case{'.slx','.mdl'}
            domain='linktype_rmi_simulink';
        case '.m'
            domain='linktype_rmi_matlab';
        case '.sldd'
            domain='linktype_rmi_data';
        case '.mldatx'
            domain='linktype_rmi_testmgr';
        case '.slreqx'
            domain='linktype_rmi_slreq';
        otherwise
            domain='';
        end
    end
end

