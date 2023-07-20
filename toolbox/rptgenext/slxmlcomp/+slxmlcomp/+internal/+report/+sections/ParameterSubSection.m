classdef ParameterSubSection<handle



    properties(Access=private)
        JNodeDiff;
        JDriverFacade;
        JSide;
    end


    methods(Access=public)

        function obj=ParameterSubSection(jNodeDiff,jDriverFacade,jSide)
            obj.JNodeDiff=jNodeDiff;
            obj.JDriverFacade=jDriverFacade;
            obj.JSide=jSide;
        end

        function fill(obj,domDocument)
            import mlreportgen.dom.Text;
            parameterDiffs=obj.getParameterDiffs();
            iterator=parameterDiffs.iterator();

            if~iterator.hasNext()
                domDocument.append('');
                return
            end

            parTextStyleName='Parameters';
            while iterator.hasNext()
                parDiff=iterator.next();
                param=parDiff.getSnippet(obj.JSide);

                if iterator.hasNext()
                    newLine=newline;
                else
                    newLine='';
                end

                if~isempty(param)
                    paramName=char(param.getDisplayString());
                    paramValue=char(param.getValue());

                    parameterEntry=Text(...
                    sprintf('%s : %s%s',paramName,paramValue,newLine),parTextStyleName...
                    );
                    parameterEntry.WhiteSpace='preserve';
                    domDocument.append(parameterEntry);
                else
                    newLineEntry=Text(newLine,parTextStyleName);
                    newLineEntry.WhiteSpace='preserve';
                    domDocument.append(newLineEntry);
                end
            end

        end

    end


    methods(Access=private)

        function parameterDiffs=getParameterDiffs(diff)
            subComparisons=diff.JDriverFacade.getResult().getSubComparisons();
            parSubComparison=subComparisons.get(diff.JNodeDiff);
            parSubComparison=xmlcomp.internal.validateParamSubComparison(parSubComparison);
            if~isempty(parSubComparison)
                parameterDiffs=diff.getFilteredParameterDiffs(parSubComparison.getResult().get());
            else
                parameterDiffs=com.mathworks.comparisons.difference.EmptyDifferenceSet;
            end
        end

        function parameterDiffs=getFilteredParameterDiffs(~,result)
            parameterDiffs=result.getDifferences();
        end

    end

end

