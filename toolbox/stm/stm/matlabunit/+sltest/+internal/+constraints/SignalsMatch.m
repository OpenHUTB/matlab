classdef SignalsMatch<Simulink.sdi.constraints.MatchesSignal&handle





    properties(Access=private,Constant)
        Catalog=matlab.internal.Catalog('stm:ResultStrings');
    end

    properties(Hidden,SetAccess={?sltest.internal.qualifications.QualificationDelegate})
        ResultSetIDContainer sltest.internal.STMResultsIdContainer
    end

    methods
        function constraint=SignalsMatch(varargin)
            constraint@Simulink.sdi.constraints.MatchesSignal(varargin{:});
        end
    end

    methods(Access=protected)
        function aDiag=getDiagnosticForComparison(constraint,actual)
            import stm.internal.pushComparison

            aDiag=getDiagnosticForComparison@Simulink.sdi.constraints.MatchesSignal(constraint,actual);




            if isempty(constraint.DiffRunResult)
                comparisonRunID=0;
            else
                comparisonRunID=constraint.DiffRunResult.comparisonRunID;
            end

            rsIDContainer=constraint.ResultSetIDContainer;
            if~isequal(comparisonRunID,0)&&~isempty(rsIDContainer)
                tcResults=constraint.getTestCaseResults();
                if~isempty(tcResults.getComparisonRun)
                    warning(message('stm:ScriptedTest:AlreadyQualified'));
                else
                    Simulink.sdi.internal.moveRunToApp(comparisonRunID,'stm');
                    pushComparison(rsIDContainer.TestCaseID,...
                    rsIDContainer.TestCaseResultsID,...
                    rsIDContainer.ResultSetID,...
                    comparisonRunID,aDiag.IsPassed);
                end
            end



            if~isequal(comparisonRunID,0)&&~aDiag.IsPassed
                aDiag=updateDisplayTable(aDiag);
            end



            if~isempty(rsIDContainer)
                aDiag=constraint.addTestResultsCondition(aDiag);
            end
        end
    end

    methods(Access=private)
        function diag=addTestResultsCondition(constraint,diag)
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic

            linkedResultsHeader=sprintf('%s\n',constraint.Catalog.getString('SimulinkTestResultsHeader'));
            linkedResults=linkedResultsHeader+indent(constraint.generateLinkedResultsCommand())+newline;
            diag.addCondition(FormattableStringDiagnostic(linkedResults));
        end

        function linkedResultsCommand=generateLinkedResultsCommand(constraint)
            [tcResults,tcResultsID]=constraint.getTestCaseResults();
            linkedResultsCommand=CommandHyperlinkableString(tcResults.TestCasePath,['stm.internal.util.highlightTestResult(int32(',num2str(tcResultsID),'))']);
        end

        function[tcResults,tcResultsID]=getTestCaseResults(constraint)


            tcResultsID=constraint.ResultSetIDContainer.TestCaseResultsID;
            tcResults=sltest.testmanager.TestResult.getResultFromID(tcResultsID);
        end
    end
end

function diag=CommandHyperlinkableString(varargin)
    diag=matlab.unittest.internal.diagnostics.CommandHyperlinkableString(varargin{:});
end

function indObj=indent(varargin)
    indObj=matlab.unittest.internal.diagnostics.indent(varargin{:});
end

function bool=isNumericComparisonDiagnostic(aDiag)
    bool=isa(aDiag,'Simulink.sdi.internal.diagnostics.SignalComparisonDiagnostic');
end

function aDiag=updateDisplayTable(aDiag)
    import Simulink.sdi.internal.diagnostics.DiagnosticType


    needsUpdate=isNumericComparisonDiagnostic(aDiag)||...
    (aDiag.DiagnosticType~=DiagnosticType.Unaligned)&&...
    (aDiag.DiagnosticType~=DiagnosticType.InvalidData);
    if needsUpdate

        newTable=removevars(aDiag.DisplayTable,"ExpectedSignals");
        aDiag.DisplayTable=newTable;
    end
end
