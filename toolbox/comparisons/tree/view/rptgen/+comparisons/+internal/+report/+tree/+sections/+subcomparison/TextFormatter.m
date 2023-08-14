classdef TextFormatter<comparisons.internal.report.tree.sections.subcomparison.SubcomparisonFormatter



    methods(Access=public)

        function bool=canHandle(~,subcomparison)
            textClass=?comparisons.text.viewmodel.mfzero.TextDiffView;
            bool=isa(subcomparison,textClass.Name);
        end

        function formattedSubcomparison=getFormattedSubcomparison(obj,subcomparison,side)
            formattedSubcomparison=[];
            for s=subcomparison
                document=s.documents(side);
                showLineNumbers=s.options.showLineNumbers;
                if~isempty(document.lines)
                    for line=document.lines.toArray
                        formattedSubcomparison=[formattedSubcomparison,obj.getFormattedLine(line,showLineNumbers)];%#ok<AGROW>
                    end
                end
            end
        end

    end

    methods(Access=private)

        function formattedLine=getFormattedLine(~,line,showLineNumbers)
            import mlreportgen.dom.Text
            lineText=strrep(line.lineText,newline,'');
            if showLineNumbers
                lineString=sprintf('%s | %s',num2str(line.lineNumber),lineText);
            else
                lineString=lineText;
            end
            formattedLine=Text(lineString,'Parameters');
            formattedLine.WhiteSpace='preserve';
        end
    end

end

