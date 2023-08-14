classdef CombinedViewFormatter<comparisons.internal.report.tree.sections.subcomparison.SubcomparisonFormatter



    methods(Access=public)

        function bool=canHandle(~,subcomparison)
            combinedClass=?comparisons.internal.CombinedView;
            bool=isa(subcomparison,combinedClass.Name);
        end

        function formattedSubcomparison=getFormattedSubcomparison(obj,subcomparison,side)
            import mlreportgen.dom.Text
            formattedSubcomparison=[];

            views=subcomparison.getViews';
            numViews=length(views);
            for i=1:numViews
                viewIsHandled=false;
                for f=obj.getSupportedFormatters()
                    if f{1}.canHandle(views{i})
                        viewIsHandled=true;
                        formattedSubcomparison=[formattedSubcomparison,f{1}.getFormattedSubcomparison(views{i},side)];%#ok<AGROW>
                    end
                end

                if viewIsHandled&&i<numViews
                    newlineText=Text(newline);
                    formattedSubcomparison=[formattedSubcomparison,newlineText];%#ok<AGROW>
                end
            end

        end

    end

    methods(Access=private)

        function formatters=getSupportedFormatters(~)
            formatters={...
            comparisons.internal.report.tree.sections.subcomparison.CombinedViewFormatter(),...
            comparisons.internal.report.tree.sections.subcomparison.ParameterFormatter(),...
            comparisons.internal.report.tree.sections.subcomparison.TextFormatter()...
            };
        end

    end

end