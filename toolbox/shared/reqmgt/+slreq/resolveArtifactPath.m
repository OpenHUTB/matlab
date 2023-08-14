













function resolved=resolveArtifactPath(artifact,domain)

    if nargin==1




        if ischar(artifact)
            if any(artifact=='.')
                resolved=artifact;
            else
                modelName=strtok(artifact,':');
                try
                    resolved=get_param(modelName,'FileName');
                catch ex %#ok<NASGU>

                    resolved='';
                end
            end
        else

            resolved=get_param(artifact,'FileName');
        end

    else




        resolved=findArtifactPath(artifact,domain);

    end

end

function resolved=findArtifactPath(artifact,domain)

    resolved='';

    if ischar(artifact)

        switch domain
        case 'linktype_rmi_simulink'
            if dig.isProductInstalled('Simulink')&&is_simulink_loaded()&&~any(artifact=='.')
                try
                    resolved=get_param(artifact,'FileName');
                catch ex %#ok<NASGU>
                end
            end
        case 'linktype_rmi_matlab'




        case 'linktype_rmi_data'
            resolved=rmide.resolveDict(artifact);

        otherwise

        end

        if isempty(resolved)
            fromWhich=which(artifact);
            if~isempty(fromWhich)

                [fDir,~,fExt]=fileparts(fromWhich);
                if isempty(fDir)||isempty(fExt)
                    error(message('Slvnv:slreq:IsNotFilePath',fromWhich));
                else
                    resolved=fromWhich;
                end
            else
                resolved=artifact;
            end
        end

    elseif strcmp(domain,'linktype_rmi_simulink')

        resolved=get_param(artifact,'FileName');

    else
        warning('slreq.resolveArtifact(): unable to resolve "%s"',disp(artifact));
    end

end