






function cmps=getComponents(this,varargin)
    p=inputParser();
    p.addParameter('types',Advisor.component.Types.empty(),...
    @(x)(isa(x,'Advisor.component.Types')));
    p.addParameter('ids',{},@iscell);
    p.parse(varargin{:});
    in=p.Results;

    cmps=Advisor.component.Component.empty();



    if isempty(in.types)
        ids=this.getComponentIDs();
    else
        ids={};
        for n=1:length(in.types)
            if this.ByTypeCache.isKey(in.types(n).double())
                ids=[ids,...
                this.ByTypeCache(in.types(n).double())];%#ok<AGROW>

            elseif in.types(n)==Advisor.component.Types.LibraryBlock
                props.IsLinked=true;
                libCompIDs=this.getComponentsWithProperties(props,[]);
                ids=[ids,libCompIDs];%#ok<AGROW>
            end
        end
    end

    if~isempty(in.ids)
        ids=intersect(ids,in.ids);
    else
        ids=unique(ids);
    end

    for n=length(ids):-1:1
        cmp=this.getComponent(ids{n});
        cmps(n)=cmp;
    end
end