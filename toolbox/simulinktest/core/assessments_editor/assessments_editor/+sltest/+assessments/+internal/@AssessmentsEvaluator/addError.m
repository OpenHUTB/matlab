function addError(self,varargin)
    import sltest.assessments.internal.AssessmentsException;
    if isa(varargin{1},'MException')
        assert(length(varargin)==1);
        self.errors(end+1)=AssessmentsException(varargin{1});
    else
        self.errors(end+1)=AssessmentsException(message(varargin{:}));
    end
end