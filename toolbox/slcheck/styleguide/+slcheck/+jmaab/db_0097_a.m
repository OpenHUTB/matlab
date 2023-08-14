classdef db_0097_a<slcheck.subcheck
    methods
        function obj=db_0097_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0097_a';
        end

        function result=run(this)
            result=false;

            sigObj=this.getEntity();

            if~strcmp(get_param(sigObj,'SegmentType'),'trunk')
                return;
            end

            svc=slcheck.services.PositionalMapService;

            labelrect=svc.getSignalLabelPositions(sigObj);

            if isempty(labelrect)
                return;
            end

            if svc.instance.getNumElementsInRect(get_param(get_param(sigObj,'parent'),'handle'),labelrect)>1
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Signal',sigObj);
                result=this.setResult(vObj);
            end

        end
    end
end



