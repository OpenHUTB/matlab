classdef FPGAConstraint<SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint






    properties(Constant)
        Index=SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.HardwareConstraint;
    end
    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory)
        function this=FPGAConstraint(modelName)


            this=this@SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint(modelName);


            specificWordLength=this.MinimumWordLength:this.MaximumWordLength;


            setMultiword(this,SimulinkFixedPoint.AutoscalerConstraints.Multiword.Factory.getMultiword([]));


            this.ChildConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],specificWordLength,[]);
        end
    end
    methods(Access=protected)
        function wordLengths=getWordLengthsToDisplay(this)

            specificWL=this.ChildConstraint.SpecificWL;
            wordLengths=sprintf('%g to %g',specificWL(1),specificWL(end));
        end
    end
end


