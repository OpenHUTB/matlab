function out=getLinkArtifact(linkTarget)
    out=[];

    if~isempty(linkTarget)
        if isa(linkTarget,'slreq.data.Requirement')

            if strcmpi(linkTarget.domain,'linktype_rmi_slreq')
                reqSet=linkTarget.getReqSet;
                out=reqSet.filepath;
            else
                out=which(linkTarget.artifactUri);
                if isempty(out)
                    out=linkTarget.artifactUri;
                end
            end

        else
            out=linkTarget.artifactUri;
        end
    end
end

