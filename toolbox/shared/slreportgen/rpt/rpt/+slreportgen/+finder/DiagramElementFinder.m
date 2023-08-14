classdef DiagramElementFinder<mlreportgen.finder.Finder







































































    properties


























        Types="All";




        IncludeCommented(1,1)logical=false;









        IncludeVariants{mustBeMember(IncludeVariants,["All","Active","ActivePlusCode"])}="Active";
















        SearchDepth=[];
    end

    properties(Constant,Hidden)
        InvalidPropertyNames=[
"IncludeCommented"
"SearchDepth"
"FindAll"
"FollowLinks"
"RegExp"
"LookUnderMasks"
"Type"
"SubViewer"
"Variants"
        ];
    end

    properties(Constant,Access=private)
        m_sltypes=[
        "Simulink.Block","block";
        "Simulink.Segment","line";
        "Simulink.Annotation","annotation";
        "Simulink.Port","port";
        ];

        m_sftypes=[
        "Stateflow.Annotation","sf_annotation";
        "Stateflow.Transition","transition";
        "Stateflow.Junction","junction";
        "Stateflow.State","state";
        "Stateflow.Box","box";
        "Stateflow.TruthTable","truthtable";
        "Stateflow.Function","function";
        "Stateflow.SLFunction","slfunction";
        "Stateflow.EMFunction","emfunction";
        "Stateflow.Port","sf_port";
        "Stateflow.AtomicSubchart","atomic_subchart";
        ];
    end

    properties(Access=private)
        m_findResultsState;




        m_variants='ActiveVariants';
    end

    methods
        function h=DiagramElementFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function set.Types(h,value)
            mustNotBeIterating(h,"Types");
            reset(h);

            types=string(value);
            nTypes=numel(types);
            if(nTypes==1)
                types=split(types," ");
                types=split(types,",");
                nTypes=numel(types);
            end

            newTypes=[];
            allTypes=[h.m_sltypes;h.m_sftypes];
            nAllTypes=size(allTypes,1);
            for i=1:nTypes
                type=types(i);
                ltype=lower(types(i));

                if(ltype=="all")
                    h.Types="All";
                    return;

                else
                    newType=[];
                    lAllTypes=lower(allTypes);
                    for j=1:nAllTypes
                        if ismember(ltype,lAllTypes(j,:))
                            newType=allTypes(j,1);
                            break;
                        end
                    end

                    if isempty(newType)
                        mustBeMember(type,["All",allTypes(:,1)']);
                    end
                    newTypes=[newTypes,newType];%#ok
                end
            end


            [~,idx]=unique(newTypes,'stable');
            newTypes=newTypes(idx);
            h.Types=newTypes(:)';
        end

        function set.IncludeCommented(h,val)
            mustNotBeIterating(h,"IncludeCommented");
            h.IncludeCommented=val;
            reset(h);
        end

        function set.IncludeVariants(h,val)
            mustNotBeIterating(h,"IncludeVariants");
            h.IncludeVariants=val;
            setVariants(h,val);
            reset(h);
        end

        function set.SearchDepth(h,val)
            if~isempty(val)
                mustBeNumeric(val)
                if~isinf(val)
                    mustBeInteger(val);
                end
            end
            h.SearchDepth=val;
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
                result=slreportgen.finder.DiagramElementResult.empty();
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

        function reset(h)
            h.m_findResultsState=struct(...
            'index',-1,...
            'results',[],...
            'nResults',0);
        end
    end

    methods(Access=private)
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

        function results=findImpl(h,container)
            hs=slreportgen.utils.HierarchyService;
            if isa(container,'mlreportgen.finder.Result')
                dhid=hs.getDiagramHID(container.Object);
            else
                dhid=hs.getDiagramHID(container);
            end
            dobj=slreportgen.utils.getSlSfHandle(dhid);

            if isa(dobj,'Stateflow.Object')
                objs=findImplSF(h,dobj);
                dPath=string(hs.getPath(dhid));
            else
                objs=findImplSL(h,dobj);
                if h.SearchDepth<=1
                    dPath=string(hs.getPath(dhid));
                else



                    dPath=[];
                end
            end

            nResults=numel(objs);
            results=slreportgen.finder.DiagramElementResult.empty(0,nResults);
            for i=1:nResults
                results(i)=slreportgen.finder.DiagramElementResult(...
                "Object",objs(i),...
                "DiagramPath",dPath);
            end
        end

        function objs=findImplSL(h,dobj)
            objs=[];


            typeArg=[];
            if ismember("All",h.Types)
                typeArg=join(h.m_sltypes(:,2)',"|");
            else
                nSLTypes=size(h.m_sltypes,1);
                for i=1:nSLTypes
                    if ismember(h.m_sltypes(i,1),h.Types)
                        typeArg=join([typeArg,h.m_sltypes(i,2)],"|");
                    end
                end
            end


            commentArg='off';
            if h.IncludeCommented
                commentArg='on';
            end


            if isempty(h.SearchDepth)
                searchDepthArg={"SearchDepth",1};
            else
                searchDepthArg={"SearchDepth",h.SearchDepth};
            end


            if~isempty(typeArg)
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    findArgs={"IncludeCommented",commentArg,...
                    "FindAll",'on',...
                    "FollowLinks",'on',...
                    "RegExp",'on',...
                    "LookUnderMasks",'all'};

                    if strcmpi(h.m_variants,'ActiveVariants')
                        findArgs(end+1)={'MatchFilter'};
                        findArgs(end+1)={@Simulink.match.activeVariants};
                    elseif strcmpi(h.m_variants,'ActivePlusCodeVariants')
                        findArgs(end+1)={'MatchFilter'};
                        findArgs(end+1)={@Simulink.match.codeCompileVariants};
                    elseif strcmpi(h.m_variants,'AllVariants')
                        findArgs(end+1)={'MatchFilter'};
                        findArgs(end+1)={@Simulink.match.allVariants};
                    end

                    findArgs(end+1)={'Type'};
                    findArgs(end+1)={char(typeArg)};
                    objs=find_system(dobj,searchDepthArg{:},findArgs{:},h.Properties{:});
                else
                    objs=find_system(dobj,...
                    "IncludeCommented",commentArg,...
                    searchDepthArg{:},...
                    "Variants",h.m_variants,...
                    "FindAll",'on',...
                    "FollowLinks",'on',...
                    "RegExp",'on',...
                    "LookUnderMasks",'all',...
                    "Type",char(typeArg),...
                    h.Properties{:});
                end

                if~isempty(objs)&&(objs(1)==dobj)
                    objs(1)=[];
                end
            end
        end

        function objs=findImplSF(h,dobj)

            typeArgs={};
            types=h.Types;
            nTypes=numel(types);


            usingSearchDepth=~isempty(h.SearchDepth);
            if usingSearchDepth
                searchDepthArg={"-depth",h.SearchDepth};
            else
                searchDepthArg={"Subviewer",dobj};
            end

            if ismember("All",h.Types)&&~usingSearchDepth
                typeArgs={};
            elseif usingSearchDepth||nTypes<7





                if ismember("All",types)

                    types=h.m_sftypes(:,1);
                    nTypes=numel(types);
                end

                for idx=1:nTypes-1
                    typeArgs=[typeArgs,{'-isa',char(types{idx}),'-or'}];%#ok
                end
                typeArgs={[typeArgs,{'-isa',char(types{end})}]};
            else



                supportedTypes=h.m_sftypes(:,1);
                nSupportedTypes=numel(supportedTypes);
                for idx=1:nSupportedTypes
                    sftype=supportedTypes{idx};
                    if~ismember(sftype,types)
                        typeArgs=[typeArgs,{'-not','-isa',char(sftype)}];%#ok
                    end
                end
            end


            commentArgs={};
            if~h.IncludeCommented
                commentArgs={...
                '-not','IsExplicitlyCommented',true,...
                '-not','IsImplicitlyCommented',true};
            end


            objs=find(dobj,...
            searchDepthArg{:},...
            commentArgs{:},...
            typeArgs{:},...
            h.Properties{:});
        end

        function setVariants(h,val)
            switch lower(string(val))
            case "all"
                h.m_variants='AllVariants';
            case "active"
                h.m_variants='ActiveVariants';
            case "activepluscode"
                h.m_variants='ActivePlusCodeVariants';
            end
        end
    end
end
