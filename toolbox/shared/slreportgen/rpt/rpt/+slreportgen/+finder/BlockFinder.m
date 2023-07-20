classdef BlockFinder<mlreportgen.finder.Finder







































































    properties





        BlockTypes="All";




        IncludeCommented(1,1)logical=false;









        IncludeVariants{mustBeMember(IncludeVariants,["All","Active","ActivePlusCode"])}="Active";






        SearchDepth(1,1)double=1;






        ConnectedSignal=[];
    end

    properties(Constant,Hidden)
        InvalidPropertyNames=[
        slreportgen.finder.DiagramElementFinder.InvalidPropertyNames
"BlockType"
        ];
    end

    properties(Access=private)
        m_def;
        m_findResultsState;
    end

    methods
        function h=BlockFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function set.BlockTypes(h,value)
            mustNotBeIterating(h,"BlockTypes");

            blockTypes=string(value);
            if(numel(blockTypes)==1)
                blockTypes=split(blockTypes," ");
                blockTypes=split(blockTypes,",");
            end

            if ismember("all",lower(blockTypes))
                h.BlockTypes="All";
            else
                h.BlockTypes=blockTypes(:)';
            end
            reset(h);
        end

        function set.IncludeCommented(h,val)
            mustNotBeIterating(h,"IncludeCommented");
            h.IncludeCommented=val;
            reset(h);
        end

        function set.IncludeVariants(h,val)
            mustNotBeIterating(h,"IncludeVariants");
            h.IncludeVariants=val;
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

        function set.ConnectedSignal(h,val)
            if~isempty(val)
                mustBeA(val,["slreportgen.finder.SignalResult","double"]);
            end
            h.ConnectedSignal=val;
        end

        function results=find(h)











            if(h.m_findResultsState.index==-1)
                results=findImpl(h,h.Container);
            else
                results=h.m_findResultsState.results;
            end
        end

        function result=next(h)














            if hasNext(h)
                result=h.m_findResultsState.results(h.m_findResultsState.index);
                h.m_findResultsState.index=h.m_findResultsState.index+1;
            else
                result=slreportgen.finder.BlockResult.empty();
            end
        end

        function tf=hasNext(h)























            if(h.m_findResultsState.index==-1)
                findAndCacheResults(h);
            end
            tf=(h.m_findResultsState.index>0)&&(h.m_findResultsState.index<=h.m_findResultsState.nResults);
        end
    end

    methods(Hidden)
        function result=first(h)
            if(h.m_findResultsState.index==-1)
                findAndCacheResults(h);
            elseif(h.m_findResultsState.nResults>0)
                h.m_findResultsState.index=1;
            end
            result=next(h);
        end
    end

    methods(Access=protected)
        function tf=isIterating(h)
            tf=~isempty(h.m_findResultsState)...
            &&(h.m_findResultsState.index>0)...
            &&(h.m_findResultsState.index<=h.m_findResultsState.nResults);
        end

        function results=findImpl(h,~)
            deResults=find(h.m_def);


            if~isempty(h.ConnectedSignal)
                blks=getConnectedBlocks(h.ConnectedSignal);
                blkHandles=get_param(blks,"Handle");
                resultObjs=[deResults.Object];
                matchingResults=ismember(resultObjs,[blkHandles{:}]);
                deResults=deResults(matchingResults);
            end


            n=numel(deResults);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                deResult=deResults(i);
                results(i)=slreportgen.finder.BlockResult(...
                "Object",deResult.Object,...
                "DiagramPath",deResult.DiagramPath,...
                "Tag",deResult.Tag);
            end
        end

        function findAndCacheResults(h)
            results=findImpl(h,h.Container);
            if~isempty(results)
                h.m_findResultsState.results=results;
                h.m_findResultsState.index=1;
                h.m_findResultsState.nResults=numel(results);
            else
                h.m_findResultsState.results=results;
                h.m_findResultsState.index=0;
                h.m_findResultsState.nResults=0;
            end
        end

        function reset(h)
            def=h.m_def;
            if(h.BlockTypes=="All")
                props=h.Properties;
            else
                props=[h.Properties,{'blocktype',char(join(h.BlockTypes,"|"))}];
            end

            if isempty(def)
                h.m_def=slreportgen.finder.DiagramElementFinder(...
                "Container",h.Container,...
                "Types","block",...
                "Properties",props,...
                "IncludeVariants",h.IncludeVariants,...
                "IncludeCommented",h.IncludeCommented,...
                "SearchDepth",h.SearchDepth);

            else
                def.Container=h.Container;
                def.Properties=props;
                def.IncludeCommented=h.IncludeCommented;
                def.IncludeVariants=h.IncludeVariants;
                def.SearchDepth=h.SearchDepth;
            end

            h.m_findResultsState=struct(...
            'index',-1,...
            'results',[],...
            'nResults',0);
        end
    end
end

function connectedBlocks=getConnectedBlocks(signal)
    if isa(signal,"slreportgen.finder.SignalResult")
        srcBlk=signal.SourceBlock;
        sigObj=signal.Object;
    else
        srcBlk=string(get_param(signal,"Parent"));
        sigObj=signal;
    end

    connectedBlocks=[srcBlk;...
    slreportgen.utils.traceSignal(sigObj,Nonvirtual=false)];
end