classdef AnnotationFinder<mlreportgen.finder.Finder





























































    properties















        SearchDepth=[];
    end

    properties(Constant,Hidden)
        InvalidPropertyNames=[
        slreportgen.finder.DiagramElementFinder.InvalidPropertyNames
        ];
    end

    properties(Access=private)
        m_def;
    end

    methods
        function h=AnnotationFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function set.SearchDepth(h,val)
            mustNotBeIterating(h,"SearchDepth");
            if~isinf(val)
                mustBeNumeric(val);
            end
            h.SearchDepth=val;
            reset(h);
        end

        function results=find(h)











            deResults=find(h.m_def);
            n=numel(deResults);
            results=slreportgen.finder.AnnotationResult.empty(0,n);
            for i=1:n
                deResult=deResults(i);
                results(i)=slreportgen.finder.AnnotationResult(...
                "Object",deResult.Object,...
                "Tag",deResult.Tag);
            end
        end

        function result=next(h)














            deResult=next(h.m_def);
            result=slreportgen.finder.AnnotationResult(...
            "Object",deResult.Object,...
            "Tag",deResult.Tag);
        end

        function tf=hasNext(h)























            tf=hasNext(h.m_def);
        end
    end

    methods(Hidden)
        function result=first(h)
            result=first(h.m_def);
        end
    end

    methods(Access=protected)
        function tf=isIterating(h)
            tf=~isempty(h.m_def)&&isIterating(h.m_def);
        end

        function reset(h)
            def=h.m_def;
            if isempty(def)
                h.m_def=slreportgen.finder.DiagramElementFinder(...
                "Container",h.Container,...
                "Types",["annotation","sf_annotation"],...
                "Properties",h.Properties,...
                "SearchDepth",h.SearchDepth);
            else
                def.Container=h.Container;
                def.Properties=h.Properties;
                def.SearchDepth=h.SearchDepth;
            end
        end
    end
end

