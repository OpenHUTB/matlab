classdef HTMLAdapter<slreq.adapters.ExternalDomainAdapter



    methods
        function this=HTMLAdapter()
            this@slreq.adapters.ExternalDomainAdapter('linktype_rmi_html');
        end

        function str=getSummary(~,artifact,id)
            if isempty(artifact)
                str=sprintf('%s',artifact);
            else
                str=sprintf('%s (%s)',artifact,id);
            end
        end

        function str=getTooltip(this,artifact,id)
            str=this.getSummary(artifact,id);
        end
    end
end
