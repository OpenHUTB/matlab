classdef(Sealed)jc_0121_b<slcheck.subcheck
%#ok<*AGROW>
    methods
        function obj=jc_0121_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0121_b';
        end

        function result=run(this)
            result=false;
            blockHandle=this.getEntity();

            if isempty(blockHandle)
                return;
            end

            sumBlock=get(blockHandle);

            inputs=strrep(sumBlock.Inputs,'|','');

            if length(inputs)<2
                return;
            end

            if strcmp(inputs(1),'+')
                return;
            end

            if strcmp(inputs(1),'-')
                svc=slcheck.services.GraphService.getInstance();
                data=svc.getData(get_param(sumBlock.Parent,'handle'));
                if data.in_loop(data.handles==blockHandle)


                    portObj=get_param(sumBlock.PortHandles.Inport(1),'Object');
                    if~isempty(portObj.Line)
                        lineObj=get_param(portObj.Line,'Object');
                        if~isempty(lineObj.SrcBlockHandle)
                            if data.in_loop(data.handles==lineObj.SrcBlockHandle)
                                return;
                            end
                        end
                    end
                end
            end

            vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
            ModelAdvisor.ResultDetail.setData(vObj,'SID',blockHandle);
            result=this.setResult(vObj);
        end
    end
end