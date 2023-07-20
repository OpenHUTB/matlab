classdef MixedHardwareConstraint<SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint







    properties(Constant)
        Index=SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.HardwareConstraint;
    end
    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.HardwareConstraintAndHardwareConstraint)
        function this=MixedHardwareConstraint(hardwareConstraint1,hardwareConstraint2)


            this=this@SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint([hardwareConstraint1.ModelName,hardwareConstraint2.ModelName]);



            this.ChildConstraint=hardwareConstraint1.ChildConstraint+hardwareConstraint2.ChildConstraint;


            setMultiword(this,hardwareConstraint1.Multiword+hardwareConstraint2.Multiword);
        end
    end
    methods(Access=protected)
        function wordLengths=getWordLengthsToDisplay(this)
            if any(diff(this.ChildConstraint.SpecificWL)-1)

                wordLengths=sprintf('%g,',this.ChildConstraint.SpecificWL);
                wordLengths(end)=[];
            else

                specificWL=this.ChildConstraint.SpecificWL;
                wordLengths=sprintf('%g to %g',specificWL(1),specificWL(end));
            end
        end
    end
end



