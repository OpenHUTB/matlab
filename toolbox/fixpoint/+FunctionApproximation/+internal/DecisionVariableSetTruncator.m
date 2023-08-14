classdef DecisionVariableSetTruncator







    properties(Hidden)
        ConstraintTracker=[]
    end

    methods
        function decisionVariableSets=truncate(this,problemObject,options,decisionVariableSets)
            if(options.Interpolation~="Linear")&&(problemObject.NumberOfInputs>1)





                return;
            end

            discardSet=false(1,numel(decisionVariableSets));
            rangeObject=FunctionApproximation.internal.Range(problemObject.InputLowerBounds,problemObject.InputUpperBounds);
            for ii=1:numel(decisionVariableSets)
                if~isempty(this.ConstraintTracker)&&~this.ConstraintTracker.advance()
                    break;
                end


                dataTypes=decisionVariableSets(ii).StorageTypes(1:end-1);
                nPoints=cellfun(@(x)numel(x),problemObject.SamplingGrid);
                [values,grid]=FunctionApproximation.internal.getValues(problemObject.InputFunctionWrapper,dataTypes,rangeObject,nPoints);
                F=griddedInterpolant(grid,values);



                if options.Interpolation=="Flat"
                    F.Method='previous';
                elseif options.Interpolation=="Nearest"
                    F.Method='nearest';
                end



                interpolatedValues=F(problemObject.SamplingGrid);
                if isvector(interpolatedValues)
                    interpolatedValues=interpolatedValues';
                end



                lhsConstraint=abs(interpolatedValues-problemObject.SampledTableData);
                rhsConstraint=max(options.AbsTol,options.RelTol*abs(problemObject.SampledTableData));
                if any(lhsConstraint(:)>rhsConstraint(:))
                    discardSet(ii)=true;
                end
            end
            decisionVariableSets(discardSet)=[];
        end
    end
end


