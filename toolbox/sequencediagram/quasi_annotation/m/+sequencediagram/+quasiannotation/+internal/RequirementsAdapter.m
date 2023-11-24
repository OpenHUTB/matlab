classdef RequirementsAdapter<slreq.adapters.ExternalDomainAdapter

    properties(Constant)
        Domain='linktype_rmi_sequenceDiagramQuasiAnnotation';
    end

    methods
        function this=RequirementsAdapter()
            domain=sequencediagram.quasiannotation.internal.RequirementsAdapter.Domain;
            this@slreq.adapters.ExternalDomainAdapter(domain);
        end

        function str=getSummary(~,qaMatFile,id)
            app=sequencediagram.quasiannotation.App.getInstance();
            annotation=app.getAnnotationFromMemoryOrMatFile(qaMatFile,id);
            if~isempty(annotation)
                str=char(annotation.Label);
            else
                str='Error: Deleted Sequence Diagram Requirement';
            end
        end

        function str=getTooltip(this,artifact,id)
            str=this.getSummary(artifact,id);
        end
    end

    methods(Static)
        function register()
            domain=sequencediagram.quasiannotation.internal.RequirementsAdapter.Domain;
            aManager=slreq.adapters.AdapterManager.getInstance();
            aManager.adapterMap(domain)=sequencediagram.quasiannotation.internal.RequirementsAdapter();
        end

        function unregister()
            domain=sequencediagram.quasiannotation.internal.RequirementsAdapter.Domain;
            aManager=slreq.adapters.AdapterManager.getInstance();
            aManager.adapterMap.remove(domain);
        end
    end
end


