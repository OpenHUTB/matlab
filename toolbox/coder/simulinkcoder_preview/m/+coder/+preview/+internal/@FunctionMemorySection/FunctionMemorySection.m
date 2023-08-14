classdef FunctionMemorySection<coder.preview.internal.CodePreviewBase




    properties
EntryType
    end

    methods
        function obj=FunctionMemorySection(sourceDD,type,name)

            obj@coder.preview.internal.CodePreviewBase(sourceDD,type,name);
        end

        out=getPreview(obj)

        function out=getMemorySectionComment(obj)
            out=obj.getMemorySectionProperty(...
            'SimulinkCoderApp:ui:CommentOfMemorySectionTooltip',...
            'comment','Comment');
        end

        function out=getMemorySectionPreStatement(obj)
            out=obj.getMemorySectionProperty(...
            'SimulinkCoderApp:ui:PreStatementOfMemorySectionTooltip',...
            '','PreStatement');
        end

        function out=getMemorySectionPostStatement(obj)
            out=obj.getMemorySectionProperty(...
            'SimulinkCoderApp:ui:PostStatementOfMemorySectionTooltip',...
            '','PostStatement');
        end
    end

    methods(Access=protected)
        function out=getMemorySectionEntry(obj)

            out=obj.getEntry;
        end

        function out=getFunctionNamingRule(obj)

            out=obj.FunctionName;
        end
    end

    methods(Access=private)
        function out=getMemorySectionProperty(obj,tooltip,cls,property)
            out='';
            entry=obj.getMemorySectionEntry;
            if~isempty(entry)&&~isempty(entry.(property))
                out=[obj.getPropertyPreview(message(tooltip).getString,...
                cls,'MemorySection',obj.escapeHTML(entry.(property))),newline];
            end
        end

        out=resolveFunctionNameToken(obj,token)
    end
end
