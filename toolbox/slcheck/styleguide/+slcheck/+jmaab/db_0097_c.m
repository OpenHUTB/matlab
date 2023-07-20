classdef db_0097_c<slcheck.subcheck
    methods
        function obj=db_0097_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0097_c';
        end

        function result=run(this)
            result=false;

            sigH=this.getEntity();

            sigObj=get_param(sigH,'object');

            if~strcmp(get_param(sigH,'SegmentType'),'trunk')
                return;
            end

            rt=SLM3I.Util.getDiagram(get_param(sigH,'parent'));


            sigm3i=SLM3I.SLDomain.handle2DiagramElement(sigH);

            if sigm3i.label.isEmpty||(isempty(sigObj.Name)&&sigObj.ShowPropagatedSignals==false)
                return;
            end

            if sigm3i.label.at(1).location~=0
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Signal',sigH);
                result=this.setResult(vObj);
            end
        end

        function bSuccess=fixit(this)
            bSuccess=false;

            sigH=this.getEntity();

            rt=SLM3I.Util.getDiagram(get_param(sigH,'parent'));

            sigm3i=SLM3I.SLDomain.handle2DiagramElement(sigH);

            if sigm3i.label.isEmpty
                return;
            end

            sigLabel=sigm3i.label.at(1);

            t=M3I.Transaction(rt.model);

            sigLabel.location=0;

            t.commit();

            bSuccess=true;
        end
    end
end