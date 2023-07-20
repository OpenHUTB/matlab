classdef Increment<serdes.internal.ibisami.ami.format.IncrementCommon

...
...
...
...
...
...
...
...



    properties(Constant)
        Name="Increment";
    end
    properties
Delta
    end
    methods

        function increment=Increment(varargin)

            increment=increment@serdes.internal.ibisami.ami.format.IncrementCommon(varargin{:});
            if length(increment.Values)>=increment.StepsOrDeltaIndex
                increment.Delta=increment.Values(increment.StepsOrDeltaIndex);
            end
        end

    end
    methods
        function set.Delta(increment,delta)
            increment.Delta=delta;
            increment.setValue(delta,increment.StepsOrDeltaIndex)
            increment.DeltaToUse=delta;
        end
    end
end

