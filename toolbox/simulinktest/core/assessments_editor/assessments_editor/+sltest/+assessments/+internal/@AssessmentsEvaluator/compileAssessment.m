function[code,symbols,reservedSymbols,timeSymbols,data]=compileAssessment(self,assessmentInfo)
    code='';
    data=[];

    try
        assert(strcmp(assessmentInfo.type,'operator'),'assessmentInfo root must be of type operator');
        switch assessmentInfo.operator
        case 'trigger delay response'
            [code,data]=self.compileTriggerDelayResponse(assessmentInfo);
        otherwise
            code=self.compileOperator(assessmentInfo);
        end
    catch ME

        self.addError(ME);
    end

    self.resetTempVars();
    symbols=self.resetSymbols();
    timeSymbols=self.resetTimeSymbols();
    reservedSymbols=self.resetReservedSymbols();
end
