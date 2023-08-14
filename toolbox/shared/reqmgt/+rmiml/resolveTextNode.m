function[domain,artifact,txtId]=resolveTextNode(srcName)




    if rmisl.isSidString(srcName)
        domain='linktype_rmi_simulink';
        [artifactName,txtId]=strtok(srcName,':');
        try
            artifact=get_param(artifactName,'FileName');
        catch ex %#ok<NASGU>
            artifact=which(artifactName);
            if isempty(artifact)
                error('Unknown artifact: %s',artifactName);
            end
        end
    else
        domain='linktype_rmi_matlab';
        artifact=srcName;
        txtId='';
    end

end
