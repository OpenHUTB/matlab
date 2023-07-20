classdef AbstractConstraint<handle&matlab.mixin.Copyable









    properties(SetAccess=protected)
        Object=[];
        ElementOfObject='';
    end

    methods(Access=public)
        comments=getComments(this);
    end

    methods(Access=public)
        function setSourceInfo(this,object,elementOfObject)








            this.Object=object;
            this.ElementOfObject=elementOfObject;
        end

        function y=allowsFixedPointProposals(~)

            y=false;
        end

        function constraint=plus(this,other)


            constraint=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.add(this,other);
        end

        function fullName=getFullName(this)

            object=this.Object;
            fullName=object.getFullName;
            if isa(object,'SimulinkFixedPoint.DataObjectWrapper')
                fullName=[fullName,' ',object.Name];
            end
        end
    end

end


