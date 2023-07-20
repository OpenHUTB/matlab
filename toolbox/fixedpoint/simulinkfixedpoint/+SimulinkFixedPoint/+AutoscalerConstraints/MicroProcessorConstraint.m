classdef MicroProcessorConstraint<SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint






    properties(Constant)
        Index=SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.HardwareConstraint;
    end
    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory)
        function this=MicroProcessorConstraint(modelName)


            this=this@SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraint(modelName);


            specificWordLength=fixed.internal.modelWordLengthInfo.wordLengthsProductionHardware(this.ModelName{1});


            multiwordWordLength=specificWordLength(end);
            setMultiword(this,SimulinkFixedPoint.AutoscalerConstraints.Multiword.Factory.getMultiword(multiwordWordLength));


            lastWL=specificWordLength(end)+multiwordWordLength;
            while lastWL<=this.MaximumWordLength
                specificWordLength=[specificWordLength,lastWL];%#ok<AGROW>
                lastWL=specificWordLength(end)+multiwordWordLength;
            end
            specificWordLength=unique(specificWordLength);


            this.ChildConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],specificWordLength,[]);
        end
    end
    methods(Access=protected)
        function wordLengths=getWordLengthsToDisplay(this)

            wordLengths=sprintf('%g,',this.ChildConstraint.SpecificWL);
            wordLengths(end)=[];
        end
    end
end


