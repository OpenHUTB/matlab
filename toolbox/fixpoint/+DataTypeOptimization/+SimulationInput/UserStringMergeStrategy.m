classdef UserStringMergeStrategy<DataTypeOptimization.SimulationInput.AbstractResolutionStrategy







    properties(Constant)
        BlankCharacter='_'
    end

    methods
        function this=UserStringMergeStrategy(propertyName)
            this.PropertyName=propertyName;
        end

        function siElement=execute(this,siLeft,siRight)



            siElement=[siLeft.UserString,this.BlankCharacter,siRight.UserString];
        end
    end

end