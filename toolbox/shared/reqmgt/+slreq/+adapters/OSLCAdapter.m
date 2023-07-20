classdef OSLCAdapter<slreq.adapters.ExternalDomainAdapter



    methods
        function this=OSLCAdapter()
            this@slreq.adapters.ExternalDomainAdapter('linktype_rmi_oslc');





            if isempty(this.registration)
                this.registration=oslc.registerDomain();

            end

            this.icon=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','unknown.png');
        end

        function str=getSummary(this,artifact,id)
            str=feval(this.registration.UrlLabelFcn,artifact,'',id);
        end

        function str=getTooltip(this,~,~)
            str=this.registration.Label;
        end


        function url=getURL(~,artifactUri,artifactId)
            url=oslc.getNavURL(artifactUri,artifactId);
        end
    end
end
