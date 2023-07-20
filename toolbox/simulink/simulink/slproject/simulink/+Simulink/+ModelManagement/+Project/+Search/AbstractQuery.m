classdef(Abstract)AbstractQuery<matlab.mixin.Heterogeneous




    properties(Constant,Abstract)
ValueQuery
PathQuery
    end

    methods
        function addResults(obj,result,token,values,paths)
            for n=find(contains(lower({values.Value}),lower(token)))
                [match,location]=obj.createResult(token,values(n).Value,paths(n).Value);
                result.addMatch(match,location);
            end
        end

        [match,location]=createResult(obj,token,value,path);
    end

end

