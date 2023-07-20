classdef URLAdapter<slreq.adapters.ExternalDomainAdapter



    methods
        function this=URLAdapter()
            this@slreq.adapters.ExternalDomainAdapter('linktype_rmi_url');
            this.icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','hyperlinkInsert.png');
        end

        function tf=isResolved(~,~,~)
            tf=true;
        end

        function str=getSummary(~,artifact,id)





            if length(artifact)>30
                artifactPart=[artifact(1:15),'...',artifact(end-10:end)];
            else
                artifactPart=artifact;
            end
            if isempty(id)
                str=artifactPart;
            else
                if length(id)>20
                    idPart=['...',id(end-15:end)];
                else
                    idPart=id;
                end
                str=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',idPart,artifactPart));
            end
        end

        function str=getTooltip(~,artifact,~)
            str=sprintf('%s',artifact);
        end

        function url=getURL(~,artifact,id)

            if isempty(id)

                url=artifact;
            else


                if id(1)=='#'
                    url=[artifact,id];
                elseif id(1)=='@'
                    url=[artifact,'#',id(2:end)];
                else
                    url=[artifact,'#',id];
                end
            end
        end
    end
end

