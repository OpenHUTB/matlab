classdef Util<handle



    properties(Access=public,Constant)
        JSideLeft=com.mathworks.comparisons.util.Side.LEFT;
        JSideRight=com.mathworks.comparisons.util.Side.RIGHT;
    end

    methods(Access=private)
        function obj=Util()
        end
    end


    methods(Access=public,Static)

        function slPath=getOriginalSimulinkPath(snippet,comparisonSource)
            import slxmlcomp.internal.report.sections.Util;
            origmodelname=Util.getOriginalModelName(comparisonSource);
            memorymodelname=Util.getMemoryModelName(comparisonSource);

            slPath=regexprep(Util.getMemorySimulinkPath(snippet,comparisonSource),...
            strcat('^',memorymodelname),origmodelname);
        end

        function slPath=getMemorySimulinkPath(snippet,~)
            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportUtils;
            slPath=char(ReportUtils.getSimulinkPath(snippet));
        end

        function scaleImageToWidthInCM(image,width)
            oldWidth=str2double(regexp(image.Width,'[0-9]*','match','once'));
            oldHeight=str2double(regexp(image.Height,'[0-9]*','match','once'));
            ratio=oldHeight/oldWidth;

            maxHeight=21;
            if ratio*width<maxHeight
                image.Width=[num2str(width),'cm'];
                image.Height=[num2str(ratio*width),'cm'];
            else
                image.Height=[num2str(maxHeight),'cm'];
                image.Width=[num2str(maxHeight/ratio),'cm'];
            end
        end

        function modelName=getOriginalModelName(comparisonSource)
            source=slxmlcomp.internal.report.sections.Util.getComparisonSourceToUse(comparisonSource);
            file=char(source.getModelData().getOriginalFile());
            [~,modelName,~]=fileparts(file);
        end

        function modelName=getMemoryModelName(comparisonSource)
            source=slxmlcomp.internal.report.sections.Util.getComparisonSourceToUse(comparisonSource);
            file=char(source.getModelData().getFileToUseInMemory());
            [~,modelName,~]=fileparts(file);
        end

        function matches=isDiffBySnippetTagName(diff,tagName)
            import slxmlcomp.internal.report.sections.Util;
            function matches=matchName(snippet)
                matches=strcmp(char(snippet.getTagName()),tagName);
            end

            matches=Util.isDiffBySnippetCondition(diff,@matchName);
        end

        function matches=isDiffBySnippetCondition(diff,condition)
            matches=false;
            snippets=diff.getSnippets().iterator();
            while(snippets.hasNext())
                snippet=snippets.next();
                if(~isempty(snippet)&&condition(snippet))
                    matches=true;
                    return;
                end
            end
        end

        function matches=isBlockDiagramRootDiff(diff)
            import slxmlcomp.internal.report.sections.Util;
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.blockdiagram.BlockDiagramNodeUtils;
            matches=Util.isDiffBySnippetCondition(...
            diff,...
            @(snippet)BlockDiagramNodeUtils.isBlockDiagramNode(snippet)...
            );
        end


        function title=getBasicDiffName(diff)

            snippets=diff.getSnippets().iterator();

            title='';
            while(snippets.hasNext())
                snippet=snippets.next();
                if(~isempty(snippet))
                    title=char(snippet.getName());
                    return
                end
            end

        end

        function file=getOriginalFileFromSource(slxSource)
            source=slxmlcomp.internal.report.sections.Util.getComparisonSourceToUse(slxSource);
            file=char(source.getModelData().getOriginalFile());
        end

    end

    methods(Access=private,Static)

        function source=getComparisonSourceToUse(source)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.comparison.SLXEntryComparisonSource;
            if isa(source,'SLXEntryComparisonSource')
                source=source.getParentSource();
            end
        end

    end

end

