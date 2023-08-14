classdef ParameterFormatter<comparisons.internal.report.tree.sections.subcomparison.SubcomparisonFormatter



    methods(Access=public)

        function bool=canHandle(~,subcomparison)
            paramClass=?comparisons.viewmodel.parameter.mfzero.ParameterTable;
            bool=isa(subcomparison,paramClass.Name);
        end

        function formattedSubcomparison=getFormattedSubcomparison(obj,subcomparison,side)
            formattedSubcomparison=[];
            for s=subcomparison
                for entry=s.entries.toArray()
                    if~isempty(entry.parameters(side).parameter)
                        formattedSubcomparison=[formattedSubcomparison,obj.getFormattedParameter(entry.parameters(side).parameter(1))];%#ok<AGROW>
                    end
                end
            end
        end

    end

    methods(Access=private)

        function formattedParameter=getFormattedParameter(~,parameter)
            import mlreportgen.dom.Text
            parameterString=sprintf('%s : %s%s',parameter.name,parameter.value);
            formattedParameter=Text(parameterString,'Parameters');
            formattedParameter.WhiteSpace='preserve';
        end
    end

end

