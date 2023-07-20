classdef subcheck_jc_0770<slcheck.subcheck
    properties(Access=private)
        Position=0;
        Tolerance=8;
    end


    methods
        function obj=subcheck_jc_0770(InitParams)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID=InitParams.Name;
            obj.Position=InitParams.Position;
        end

        function result=run(this)
            result=false;

            SFStateObject=this.getEntity();

            if isempty(SFStateObject)
                return;
            end


            if~isprop(SFStateObject,'LabelString')
                return;
            end

            label=strtrim(SFStateObject.LabelString);













            if strcmp(label,'?')
                return;
            end




            if isempty(label)
                return;
            end

            if 0==this.Position
                reference=SFStateObject.SourceEndpoint;
            elseif 1==this.Position
                reference=SFStateObject.MidPoint;
            else
                return;
            end

            destinationPoint=SFStateObject.DestinationEndpoint;
            sourcePoint=SFStateObject.SourceEndpoint;



            labelPosition=SFStateObject.LabelPosition;


            circle.center=reference;
            circle.radius=round(sqrt(...
            (sourcePoint(1)-destinationPoint(1))^2+...
            (sourcePoint(2)-destinationPoint(2))^2...
            ))/this.Tolerance;




            if ifOverLaps(circle,labelPosition)
                return;
            end

            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',SFStateObject);
            result=this.setResult(vObj);

        end
    end
end



function flag=ifOverLaps(circle,rect)











    circleDistance.x=abs(circle.center(1)-(rect(1)+rect(3)/2));
    circleDistance.y=abs(circle.center(2)-(rect(2)+rect(4)/2));


    if(circleDistance.x>(rect(3)/2+circle.radius))
        flag=false;
        return;
    end

    if(circleDistance.y>(rect(4)/2+circle.radius))
        flag=false;
        return;
    end

    if(circleDistance.x<=(rect(3)/2))
        flag=true;
        return;
    end

    if(circleDistance.y<=(rect(4)/2))
        flag=true;
        return;
    end

    cornerDistance_sq=(circleDistance.x-rect(3)/2)^2+...
    (circleDistance.y-rect(4)/2)^2;

    if cornerDistance_sq<=circle.radius^2
        flag=true;
    else
        flag=false;
    end

end

