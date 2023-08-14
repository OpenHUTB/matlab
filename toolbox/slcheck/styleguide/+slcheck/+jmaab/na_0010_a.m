classdef na_0010_a<slcheck.subcheck
    methods
        function obj=na_0010_a()
            obj.CompileMode='PostCompile';
            obj.Licenses={''};
            obj.ID='na_0010_a';
        end

        function result=run(this)
            result=false;
            entity=this.getEntity();
            entity_obj=get_param(entity,'object');

            if isa(entity_obj,'Simulink.Mux')
                lh=entity_obj.LineHandles.Outport(1);

                if~ishandle(lh)
                    return;
                end

                if isSignalBus(lh)





                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',entity);
                    result=this.setResult(vObj);
                    return;
                end


            elseif isa(entity_obj,'Simulink.Demux')
                lh=entity_obj.LineHandles.Inport(1);

                if~ishandle(lh)
                    return;
                end

                if isSignalBus(lh)



                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',entity);
                    result=this.setResult(vObj);
                    return;
                end

            else
                return;
            end


        end
    end
end

function[b,srcPortHandle,busType]=isSignalBus(hLine)



    srcPortHandle=get_param(hLine,'SrcPortHandle');
    b=false;
    busType=[];
    if~isempty(srcPortHandle)&&ishandle(srcPortHandle)&&isfloat(srcPortHandle)
        busType=get_param(srcPortHandle,'CompiledBusType');
        if~isempty(busType)&&~strcmpi(busType,'NOT_BUS')
            b=true;
        end
    end
end