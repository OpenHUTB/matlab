classdef StateFinder<mlreportgen.finder.Finder












































    properties



        IncludeCommented(1,1)logical=false;
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
        function h=StateFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function set.IncludeCommented(h,val)
            mustNotBeIterating(h,"IncludeCommented");
            h.IncludeCommented=val;
            reset(h);
        end

        function results=find(h)












            results=find(h.m_def);
        end

        function result=next(h)














            result=next(h.m_def);
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
                "Types","state",...
                "Properties",h.Properties,...
                "IncludeCommented",h.IncludeCommented);

            else
                def.Container=h.Container;
                def.Properties=h.Properties;
                def.IncludeCommented=h.IncludeCommented;
            end
        end
    end
end
