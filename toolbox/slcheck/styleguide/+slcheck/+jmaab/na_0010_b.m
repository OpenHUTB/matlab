classdef na_0010_b<slcheck.subcheck
    methods
        function obj=na_0010_b()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0010_b';
        end

        function result=run(this)
            result=false;
            entity=this.getEntity();

            if~(isa(get_param(entity,'object'),'Simulink.Mux'))
                return;
            end



            entity_obj=get_param(entity,'object');
            line_handles=entity_obj.LineHandles;



            for idx=1:numel(line_handles.Inport)
                if~ishandle(line_handles.Inport(idx))
                    continue;
                end


                lh=get_param(line_handles.Inport(idx),'object');
                if ishandle(lh.SrcPortHandle)&&~strcmp(get_param(lh.SrcPortHandle,'CompiledBusType'),'NOT_BUS')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',entity);
                    result=this.setResult(vObj);
                    return;
                end
            end

        end
    end
end

