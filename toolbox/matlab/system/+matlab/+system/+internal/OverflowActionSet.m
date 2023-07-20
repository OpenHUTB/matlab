classdef OverflowActionSet<matlab.system.StringSet




    properties(Access=protected,Constant)
        AllValues={'Wrap','Saturate'};
    end

    methods
        function obj=OverflowActionSet(values)







            allValues=matlab.system.internal.OverflowActionSet.AllValues;
            if nargin<1
                values=allValues;
            elseif isempty(values)
                matlab.system.internal.error('MATLAB:system:OverflowActionSet:Empty');
            elseif iscellstr(values)||isstring(values)
                invalidValuesInd=~ismember(values,allValues);
                if any(invalidValuesInd)
                    invalidValues=values(invalidValuesInd);
                    matlab.system.internal.error('MATLAB:system:OverflowActionSet:InvalidValue',invalidValues{1});
                end
            end
            obj@matlab.system.StringSet(values);
        end
    end
end
