classdef Steps<serdes.internal.ibisami.ami.format.IncrementCommon

...
...
...
...
...



    properties(Constant)
        Name="Steps";
    end
    properties
StepsCount
    end
    methods

        function steps=Steps(varargin)

            steps=steps@serdes.internal.ibisami.ami.format.IncrementCommon(varargin{:});
            if length(steps.Values)>=steps.StepsOrDeltaIndex
                steps.StepsCount=steps.Values(steps.StepsOrDeltaIndex);
            end
        end

    end
    methods
        function set.StepsCount(stepsObj,stepsValue)
            if ischar(stepsValue)||isstring(stepsValue)
                stepsValue=str2double(stepsValue);
            end
            stepsObj.StepsCount=stepsValue;
            max=stepsObj.Max;
            if ischar(max)||isstring(max)
                max=str2double(max);
            end
            min=stepsObj.Min;
            if ischar(min)||isstring(min)
                min=str2double(min);
            end
            delta=(max-min)/stepsValue;
            stepsObj.DeltaToUse=delta;
            stepsObj.setValue(stepsValue,stepsObj.StepsOrDeltaIndex)
        end
    end
end

