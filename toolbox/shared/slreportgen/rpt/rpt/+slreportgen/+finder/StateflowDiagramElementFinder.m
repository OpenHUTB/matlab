classdef StateflowDiagramElementFinder<mlreportgen.finder.Finder





































































    properties






















        Types="All";

        IncludeCommented(1,1)logical=false;










        SearchDepth=[];
    end

    properties(Constant,Hidden)
        InvalidPropertyNames=[
        slreportgen.finder.DiagramElementFinder.InvalidPropertyNames
        ];
    end

    properties(Constant,Access=private)
        m_sfTypes=[
        "Stateflow.Annotation","annotation";
        "Stateflow.Transition","transition";
        "Stateflow.Junction","junction";
        "Stateflow.State","state";
        "Stateflow.Box","box";
        "Stateflow.TruthTable","truthtable";
        "Stateflow.Function","function";
        "Stateflow.SLFunction","slfunction";
        "Stateflow.EMFunction","emfunction";
        "Stateflow.Port","port";
        "Stateflow.AtomicSubchart","atomic_subchart";
        ];
    end

    properties(Access=private)
        m_def;
    end

    methods
        function h=StateflowDiagramElementFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function set.Types(h,value)
            mustNotBeIterating(h,"Types");

            types=string(value);
            nTypes=numel(types);
            if(nTypes==1)
                types=split(types);
                nTypes=numel(types);
            end

            newTypes=[];
            lsfTypes=lower(h.m_sfTypes);
            nSFTypes=size(lsfTypes,1);
            for i=1:nTypes
                type=lower(types(i));
                if(type=="all")
                    h.Types="All";
                    return;
                else
                    sfType=[];
                    for j=1:nSFTypes
                        if ismember(type,lsfTypes(j,:))
                            sfType=h.m_sfTypes(j,1);
                            break;
                        end
                    end

                    if isempty(sfType)
                        mustBeMember(type,["All",h.m_sfTypes(:,1)']);
                    end
                    newTypes=[newTypes,sfType];%#ok
                end
            end


            [~,idx]=unique(newTypes,'stable');
            newTypes=newTypes(idx);
            h.Types=newTypes(:)';

            reset(h);
        end

        function set.IncludeCommented(h,val)
            mustNotBeIterating(h,"IncludeCommented");
            h.IncludeCommented=val;
            reset(h);
        end

        function set.SearchDepth(h,val)
            mustNotBeIterating(h,"SearchDepth");
            if~isinf(val)
                mustBeInteger(val);
            end
            h.SearchDepth=val;
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
            if(h.Types=="All")
                types={...
                'Stateflow.Annotation','transition','junction'...
                ,'state','box','truthtable','sf_port'...
                ,'function','slfunction','emfunction','atomic_subchart'};
            else
                types=h.Types;
            end

            def=h.m_def;
            if isempty(def)
                h.m_def=slreportgen.finder.DiagramElementFinder(...
                "Container",h.Container,...
                "Types",types,...
                "Properties",h.Properties,...
                "IncludeCommented",h.IncludeCommented,...
                "SearchDepth",h.SearchDepth);
            else
                def.Container=h.Container;
                def.Types=types;
                def.Properties=h.Properties;
                def.IncludeCommented=h.IncludeCommented;
                def.SearchDepth=h.SearchDepth;
            end
        end
    end
end

