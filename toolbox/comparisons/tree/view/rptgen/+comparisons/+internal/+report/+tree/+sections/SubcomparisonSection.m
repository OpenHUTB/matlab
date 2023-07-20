classdef SubcomparisonSection<handle



    properties(Access=private)
MCOSView
Entry
Side
ReportFormat

        SubcomparisonFormatters cell={...
        comparisons.internal.report.tree.sections.subcomparison.CombinedViewFormatter(),...
        comparisons.internal.report.tree.sections.subcomparison.ParameterFormatter(),...
        comparisons.internal.report.tree.sections.subcomparison.TextFormatter()...
        }
    end

    methods(Access=public)

        function obj=SubcomparisonSection(mcosView,entry,side,rptFormat)
            obj.MCOSView=mcosView;
            obj.Entry=entry;
            obj.Side=side;
            obj.ReportFormat=rptFormat;
        end

        function fill(obj,treeEntry)
            import mlreportgen.dom.Text
            side=uint8(obj.Side);

            match=obj.Entry.match;
            subcomparison=obj.MCOSView.getSubcomparison(match);


            nodeExists=~isempty(obj.Entry.nodes(side).node);

            if~nodeExists&&~isempty(subcomparison)
                treeEntry.append('');
            else

                formattedSubcomparison=[];
                for subcomparisonFormatter=obj.SubcomparisonFormatters
                    if subcomparisonFormatter{1}.canHandle(subcomparison)
                        formattedSubcomparison=[formattedSubcomparison,...
                        subcomparisonFormatter{1}.getFormattedSubcomparison(subcomparison,side)];%#ok<AGROW>
                    end
                end

                for text=formattedSubcomparison
                    treeEntry.append(text);



                    formatIsNotPDF=(~strcmp(obj.ReportFormat,'PDF'));

                    if formatIsNotPDF&&text~=formattedSubcomparison(end)
                        newlineText=Text(newline);
                        newlineText.WhiteSpace='preserve';
                        treeEntry.append(newlineText);
                    end
                end


            end

        end

    end

end

