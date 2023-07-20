function expr=cast(self,targetType,saturate)



    try
        if(nargin<3)
            saturate=true;
        end
        expr=sltest.assessments.Cast(self,targetType,saturate);
    catch ME
        ME.throwAsCaller();
    end
end
