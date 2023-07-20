function expr=alias(self,varargin)



    try
        expr=sltest.assessments.Alias(self,varargin{:});
    catch ME
        ME.throwAsCaller();
    end
end
