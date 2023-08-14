function errors=resetErrors(self)
    errors=self.errors;
    self.errors=sltest.assessments.internal.AssessmentsException.empty();
end