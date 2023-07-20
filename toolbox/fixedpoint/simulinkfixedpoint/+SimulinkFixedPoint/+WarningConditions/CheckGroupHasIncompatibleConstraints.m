classdef CheckGroupHasIncompatibleConstraints<SimulinkFixedPoint.WarningConditions.AbstractCondition









    methods(Access=public)

        function flag=check(~,~,group)
            flag=false;
            if~isempty(group.constraints)


                if isa(group.constraints,'SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint')


                    flag=hasConflict(group.constraints);
                end
            end
        end

        function warningString=getWarning(this,~,group)
            warningString={};


            if this.check([],group)




                warningString=getConflictComments(group.constraints);
            end
        end
    end

end


