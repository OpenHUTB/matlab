classdef ReporterFactory<handle













    methods(Static)

        function reporter=makeReporter(reportOptions,varName,varValue)

























            import mlreportgen.report.internal.variable.*

            if ischar(varValue)||isstring(varValue)
                reporter=StringReporter(reportOptions,varName,varValue);

            elseif isenum(varValue)
                reporter=EnumerationReporter(reportOptions,varName,varValue);
            elseif islogical(varValue)
                if min(size(varValue))>1
                    reporter=LogicalArrayReporter(reportOptions,...
                    varName,varValue);
                elseif length(varValue)>1
                    reporter=LogicalVectorReporter(reportOptions,...
                    varName,varValue);
                else
                    reporter=LogicalScalarReporter(reportOptions,...
                    varName,varValue);
                end

            elseif isjava(varValue)
                if isa(varValue,'org.w3c.dom.Node')
                    reporter=XMLDocReporter(reportOptions,...
                    varName,varValue);
                else
                    reporter=StringReporter(reportOptions,...
                    varName,varValue);
                end

            elseif~isnumeric(varValue)&&~isempty(find(ishandle(varValue),1))
                if min(size(varValue))>1
                    reporter=ObjectArrayReporter(reportOptions,...
                    varName,varValue);
                elseif length(varValue)>1
                    reporter=ObjectVectorReporter(reportOptions,...
                    varName,varValue);
                elseif isobject(varValue)
                    if isgraphics(varValue)
                        reporter=HGObjectReporter(reportOptions,...
                        varName,varValue);
                    else
                        reporter=MCOSObjectReporter(reportOptions,...
                        varName,varValue);
                    end
                else
                    reporter=UDDObjectReporter(reportOptions,...
                    varName,varValue);
                end

            elseif isobject(varValue)&&isnumeric(varValue)





                if numel(properties(varValue))==0

                    if min(size(varValue))>1
                        reporter=NumericArrayReporter(reportOptions,...
                        varName,varValue);
                    elseif length(varValue)>1
                        reporter=NumericVectorReporter(reportOptions,...
                        varName,varValue);
                    else
                        reporter=NumericScalarReporter(reportOptions,...
                        varName,varValue);
                    end
                else

                    if min(size(varValue))>1
                        reporter=ObjectArrayReporter(reportOptions,...
                        varName,varValue);
                    elseif numel(varValue)>1
                        reporter=ObjectVectorReporter(reportOptions,...
                        varName,varValue);
                    else
                        reporter=MCOSObjectReporter(reportOptions,varName,varValue);
                    end
                end

            elseif isnumeric(varValue)
                if min(size(varValue))>1
                    reporter=NumericArrayReporter(reportOptions,...
                    varName,varValue);
                elseif length(varValue)>1
                    reporter=NumericVectorReporter(reportOptions,...
                    varName,varValue);
                else









                    reporter=NumericScalarReporter(reportOptions,...
                    varName,varValue);
                end

            elseif iscell(varValue)
                if min(size(varValue))>1
                    reporter=CellArrayReporter(reportOptions,...
                    varName,varValue);
                else
                    reporter=CellVectorReporter(reportOptions,...
                    varName,varValue);
                end

            elseif isstruct(varValue)
                if min(size(varValue))>1
                    reporter=ObjectArrayReporter(reportOptions,...
                    varName,varValue);
                elseif length(varValue)>1
                    reporter=ObjectVectorReporter(reportOptions,...
                    varName,varValue);
                else
                    reporter=StructureReporter(reportOptions,...
                    varName,varValue);
                end

            elseif isobject(varValue)
                if isempty(metaclass(varValue))
                    reporter=StringReporter(reportOptions,varName,varValue);
                elseif istable(varValue)
                    reporter=MATLABTableReporter(reportOptions,varName,varValue);
                else
                    if min(size(varValue))>1
                        reporter=ObjectArrayReporter(reportOptions,...
                        varName,varValue);
                    elseif numel(varValue)>1
                        reporter=ObjectVectorReporter(reportOptions,...
                        varName,varValue);
                    else
                        reporter=MCOSObjectReporter(reportOptions,varName,varValue);
                    end
                end

            else
                errorText=...
                getString(message("mlreportgen:report:error:unsupportedVariable",varName,class(varValue)));
                reporter=StringReporter(reportOptions,varName,errorText);
            end
        end

    end

end