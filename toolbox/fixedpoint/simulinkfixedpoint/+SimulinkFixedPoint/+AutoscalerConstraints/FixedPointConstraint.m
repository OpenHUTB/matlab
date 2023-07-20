classdef(Abstract)FixedPointConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint









    properties(Abstract,Constant)
        Index;
    end

    properties(Hidden,Constant)

        MinimumWordLength=1;
        MaximumWordLength=128;
    end

    properties(SetAccess=protected)
        SpecificSigned=string([]);
    end

    methods(Access=public)
        function y=allowsFixedPointProposals(this)


            if hasConflict(this)

                y=false;
            else

                y=true;
            end
        end

        function comments=getConflictComments(~)

            comments={};
        end

        function flag=isSigned(this)

            flag=this.SpecificSigned=="Signed";
            if isempty(flag)

                flag=false;
            end
        end

        function flag=isUnsigned(this)

            flag=this.SpecificSigned=="Unsigned";
            if isempty(flag)

                flag=false;
            end
        end
    end

    methods(Abstract)

        dataType=snapDataType(this,dataType);
        flag=hasConflict(this);
    end

    methods(Hidden)
        function validateSpecificSigned(~,val)
            if~isempty(val)&&~(ischar(val)||isstring(val))
                error(message('SimulinkFixedPoint:autoscaling:invalidSpecificSigned'));
            end
        end

        function setSignedness(this,specificSigned)
            validateSpecificSigned(this,specificSigned);
            this.SpecificSigned=string(specificSigned);
        end
    end
end


