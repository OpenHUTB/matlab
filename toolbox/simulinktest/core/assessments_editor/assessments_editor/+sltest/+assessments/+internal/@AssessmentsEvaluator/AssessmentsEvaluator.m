classdef AssessmentsEvaluator<handle


    properties(Access=private)
assessmentsInfo
symbolsInfo
symbolsInfo2
symbolsCacheSim1
namespaces
symbolList
    end

    properties(Constant)
        operatorTemplates=sltest.assessments.internal.AssessmentsEvaluator.loadTemplates();
    end

    methods
        function self=AssessmentsEvaluator(assessmentsJSON,varargin)

            parser=inputParser();
            parser.addParameter('SymbolsNamespace','symbols.',@(s)validateattributes(s,{'char','string'},{'scalartext'}));
            parser.addParameter('TimeSymbolsNamespace','timeSymbols.',@(s)validateattributes(s,{'char','string'},{'scalartext'}));
            parser.addParameter('TemporariesNamespace','temp.',@(s)validateattributes(s,{'char','string'},{'scalartext'}));
            parser.addParameter('OutputNamespace','output',@(s)validateattributes(s,{'char','string'},{'scalartext'}));
            parser.parse(varargin{:});

            self.namespaces.symbols=parser.Results.SymbolsNamespace;
            self.namespaces.timeSymbols=parser.Results.TimeSymbolsNamespace;
            self.namespaces.temporaries=parser.Results.TemporariesNamespace;
            self.namespaces.output=parser.Results.OutputNamespace;

            if~isempty(assessmentsJSON)
                data=jsondecode(assessmentsJSON);

                self.assessmentsInfo=self.tableToTree(data.AssessmentsInfo,'placeHolder');
                self.symbolsInfo=self.tableToTree(data.MappingInfo,'label');
                if isfield(data,'MappingInfo2')&&~isempty(data.MappingInfo2)
                    self.symbolsInfo2=self.tableToTree(data.MappingInfo2,'label');
                end
                self.symbolList=arrayfun(@(x)x.value,self.symbolsInfo,'UniformOutput',false);
            end
        end

        value=hasAssessments(self)
        results=evaluate(self,varargin)
        code=generateCode(self)
    end



    methods
        [symbols,conflicts]=parseSymbols(self,scopes,simIndex,modelName,prevSymbolsInfo)
        signals=parseSignals(self)
        parameters=parseParameters(self,simIndex,modelName,prevSymbolsInfo)
    end



    properties(Access=private)
        tempVars(1,:)string=string.empty()
        symbols(1,:)string=string.empty()
        reservedSymbols(1,:)string=string.empty()
        timeSymbols(1,:)string=string.empty()
        errors(1,:)sltest.assessments.internal.AssessmentsException=sltest.assessments.internal.AssessmentsException.empty()
    end

    methods
        var=makeTempVar(self,var)
        resetTempVars(self);

        addError(self,varargin)
        errors=resetErrors(self)

        addSymbols(self,symbols)
        symbols=resetSymbols(self)

        addReservedSymbols(self,symbols)
        reservedSymbols=resetReservedSymbols(self)

        addTimeSymbols(self,symbols)
        timeSymbols=resetTimeSymbols(self)

        result=getAssessmentsNames(self)
    end



    methods
        [code,symbols,reservedSymbols,timeSymbols,patternData]=compileAssessment(self,assessmentInfo)
        code=compileTime(self,timeInfo,context)
        code=compileExpression(self,exprInfo,context)
        code=compileOperator(self,operatorInfo)
        [code,patternData]=compileTriggerDelayResponse(self,trInfo)
        [code,patternData]=triggerResponseCode(self,data)
    end



    methods(Static)
        [symbol,info]=evaluateSymbol(symbolInfo,environment)
        [symbol,info]=evaluateTimeSymbol(symbolInfo,environment)
        values=evaluateParameters(parameters)
        subsArray=mtreeToSubsref(symbolName,fieldElement,exprMtree)
        symbolValue=resolveSymbolValue(symbolName,fieldElement,symbolValue)
        checkValueIsValidScalar(symbolName,value)
    end



    methods(Static)
        templates=loadTemplates()
        tree=tableToTree(table,childKey,valueKey)
    end



    methods(Static)
        value=evaluateExpression(expression,workspace)
        output=evaluateCodeBlock(code,output,workspace)
    end
end
