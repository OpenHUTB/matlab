classdef RoundingMethodSet<matlab.system.StringSet




    properties(Access=protected,Constant)
        AllValues={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
    end

    methods
        function obj=RoundingMethodSet(values)
















            allValues=matlab.system.internal.RoundingMethodSet.AllValues;
            if nargin<1
                values=allValues;
            elseif isempty(values)
                matlab.system.internal.error('MATLAB:system:RoundingMethodSet:Empty');
            elseif iscellstr(values)||isstring(values)
                invalidValuesInd=~ismember(values,allValues);
                if any(invalidValuesInd)
                    invalidValues=values(invalidValuesInd);
                    matlab.system.internal.error('MATLAB:system:RoundingMethodSet:InvalidValue',invalidValues{1});
                elseif~issorted(values)
                    matlab.system.internal.error('MATLAB:system:RoundingMethodSet:Unsorted');
                end
            end
            obj@matlab.system.StringSet(values);
        end
    end
end
