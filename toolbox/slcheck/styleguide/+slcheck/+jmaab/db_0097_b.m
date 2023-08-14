classdef db_0097_b<slcheck.subcheck
    methods
        function obj=db_0097_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0097_b';
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
























            fullPath=SLM3I.SLDomain.getSegmentPath(sigH);
            numPoints=size(fullPath,1);
            labelLocation=sigm3i.label.at(1).location;


            if labelLocation==0||labelLocation==1
                xDiff=fullPath(2,1)-fullPath(1,1);
            elseif(sigm3i.label.at(1).location>=numPoints)
                xDiff=fullPath(numPoints,1)-fullPath(numPoints-1,1);
            else
                xDiff=fullPath(labelLocation+1,1)-fullPath(labelLocation,1);
            end


            flipped=sigm3i.label.at(1).flipped;
            if(xDiff>0&&flipped)||(xDiff<0&&~flipped)
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

            sigLabel.flipped=false;

            t.commit();

            bSuccess=true;
        end
    end
end