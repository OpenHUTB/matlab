classdef DisplayUtils





    methods(Static)
        function displayBestSolution(dbUnit,options)
            fprintf('\n%s\n',message('SimulinkFixedPoint:functionApproximation:bestSolution').getString())
            fprintf('%s\n',getHeader(dbUnit,options))
            fprintf('%s\n\n',tostring(dbUnit,options))
        end

        function displayBestInfeasibleSolution(dbUnit,options)
            fprintf('\n%s\n',message('SimulinkFixedPoint:functionApproximation:bestInfeasibleSolution').getString())
            fprintf('%s\n',getHeader(dbUnit,options))
            fprintf('%s\n\n',tostring(dbUnit,options))
        end

        function displayBestSolutionAfterSolve(solutionObject,options)
            if options.Display
                dbUnit=solutionObject.DataBase.getBest();
                if dbUnit.ConstraintMet
                    FunctionApproximation.internal.DisplayUtils.displayBestSolution(dbUnit,options);
                else
                    dbUnit=solutionObject.DataBase.getBestInfeasible();
                    FunctionApproximation.internal.DisplayUtils.displayBestInfeasibleSolution(dbUnit,options);
                end

                if(solutionObject.SourceProblem.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock)...
                    &&solutionObject.percentreduction==0
                    fprintf('\n%s\n',message('SimulinkFixedPoint:functionApproximation:originalLUTBest').getString())
                end
            end
        end

        function displayExplicitValuesOnlyFor1D(options)
            if(options.Display)
                fprintf('%s\n\n',message('SimulinkFixedPoint:functionApproximation:explicitValuesNotAllowedOnlyFor',char(FunctionApproximation.BreakpointSpecification.ExplicitValues),1).getString())
            end
        end

        function displayUnableToSearchExplicitValuesForHDLOptimized(options)
            if(options.Display)
                fprintf('%s\n\n',message('SimulinkFixedPoint:functionApproximation:hdlOptimizedUnableToSearchExplicitValues').getString());
            end
        end

        function displayDBUnit(dbUnit,options)
            if(options.Display&&~isempty(dbUnit))
                fprintf('%s\n',tostring(dbUnit,options));
            end
        end

        function displayDBUnitHeader(dbUnit,options)
            if options.Display
                fprintf('%s \n',getHeader(dbUnit,options));
            end
        end

        function headerString=getClassHeaderString(classObject,postClassNameString,dimStr)
            headerString=[dimStr,' ',class(classObject)];
            if feature('hotlinks')
                headerString=[dimStr,' <a href="matlab:helpPopup ',class(classObject),'" style="font-weight:bold">',class(classObject),'</a>'];
            end
            headerString=sprintf('  %s %s\n',headerString,postClassNameString);
        end

        function stringValue=getUnmatchedFieldsString(unmatchedFields)
            stringValue=sprintf('%s\b',sprintf('%s,',string(unmatchedFields)));
        end

        function stringValue=getBoundCorrectionString(id,dimension,dataTypeString,finalValue)
            msg=message(id,dimension,[dataTypeString,' = ',num2str(finalValue)]);
            stringValue=getString(msg);
        end

        function throwError(diagnostic)
            throw(diagnostic);
        end

        function throwWarning(diagnostic)
            warning OFF BACKTRACE
            warning(message(diagnostic.identifier));
            warning ON BACKTRACE
        end

        function displayCauses(diagnostic,options)
            if options.Display&&~isempty(diagnostic)&&~isempty(diagnostic.cause)
                fprintf('\n');
                for k=1:numel(diagnostic.cause)
                    fprintf('%s\n',diagnostic.cause{k}.getReport());
                end
            end
        end

        function explicitValuesProgressStart(progressStartText,options)
            if options.Display
                fprintf(progressStartText);
            end
        end

        function explicitValuesProgressPercent(displayFormat,percentValue,options)
            if options.Display
                fprintf(displayFormat,percentValue);
            end
        end

        function explicitValuesProgressTerminate(terminateText,options)
            if options.Display
                matlab.internal.yield();
                fprintf(terminateText);
            end
        end

        function displayCompressedSolutionPercentReductionHeader(options)
            if options.Display
                stringValue=message('SimulinkFixedPoint:functionApproximation:displayCompressedSolutionPercentReductionHeader').getString();
                fprintf('- %s\n',stringValue);
            end
        end

        function displayCompressedSolutionFoundForBlockPath(solution,options)
            if options.Display
                stringValue=message('SimulinkFixedPoint:functionApproximation:displayCompressedSolutionFoundForBlockPath',...
                sprintf('%5.2f',solution.PercentReduction),...
                solution.SourceProblem.FunctionToReplace).getString();
                fprintf('\t- %s\n',stringValue);
            end
        end

        function numLUTsFound(numTables,options)
            if options.Display
                stringValue=message('SimulinkFixedPoint:functionApproximation:numLUTsFound',...
                int2str(numTables)).getString();
                fprintf('- %s\n',stringValue);
            end
        end
    end
end
