classdef CheckWordlengthExceeds<SimulinkFixedPoint.WarningConditions.AbstractCondition







    methods

        function this=CheckWordlengthExceeds()
            this.messageID={'SimulinkFixedPoint:autoscaling:multiwordWLMicro'};
        end

        function flag=check(~,result,~)




            flag=false;
            if result.hasProposedDT
                hardwareConstraint=...
                SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(...
                result.getHighestLevelParent);
                proposedDataType=result.getProposedDTContainerInfo.evaluatedNumericType;
                if isLesserThan(hardwareConstraint.Multiword,proposedDataType.WordLength)
                    flag=true;
                end
            end
        end
    end
end


