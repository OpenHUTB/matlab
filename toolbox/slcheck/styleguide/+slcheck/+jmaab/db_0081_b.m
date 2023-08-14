

classdef db_0081_b<slcheck.subcheck
    methods
        function obj=db_0081_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0081_b';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();


            if strcmp(get_param(obj,'Type'),'block')

                portcon=get_param(obj,'PortConnectivity');

                ports=get_param(obj,'Ports');

                for ip=1:ports(1)

                    if any(portcon(ip).SrcBlock==-1)&&...
...
                        ~isVariantSubsysBlk(obj)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end
                end

                for op=1:ports(2)

                    lh=get_param(obj,'LineHandles');

                    if(lh.Outport(op)==-1)&&...
...
                        ~isVariantSubsysBlk(obj)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);


                    elseif~(lh.Outport(op)==-1)

                        allsinks=get_param(lh.Outport(op),'DstPortHandle');

                        if(~isempty(allsinks)&&~isempty(find(allsinks==-1,1)))
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                            result=this.setResult(vObj);
                        end
                    end
                end
            end
        end
    end
end


function bResult=isVariantSubsysBlk(obj)
    bResult=false;

    objParent=get_param(obj,'Parent');
    if~isempty(objParent)&&~isa(get_param(objParent,'object'),'Simulink.SubSystem')
        return;
    end

    bResult=strcmpi(get_param(objParent,'Variant'),'on');
end