function nodes=getTerminalVoltages(sl)





    lSelectedNodes();
    find(sl,@lFindTopSimscapeBlocks);
    nodes=lSelectedNodes();
end

function status=lFindTopSimscapeBlocks(a)

    status=false;
    for idx=2:numel(a)
        if strcmp(lGetBlockPath(a{idx-1}),lGetBlockPath(a{idx}))
            ids=cellfun(@(n)n.id,a,'UniformOutput',false);
            find(a{end},@(nodes)lFindPortVoltageNode(nodes,ids));
            status=true;
        end
    end
end

function blockPath=lGetBlockPath(n)
    t=n.tags;
    iBlockPath=strcmp(t{1},'blockPath');
    blockPath=t{2}{iBlockPath};
end

function status=lFindPortVoltageNode(a,rootIds)


    status=false;
    if numel(a)==2&&...
        a{1}.numChildren==1&&...
        strcmp(a{2}.id,'v')&&...
        isa(a{2}.series,'simscape.logging.Series')&&...
        pm_commensurate(a{2}.series.unit,'V')

        lSelectedNodes(strjoin([rootIds,{a{end}.id}],'.'),a{end});
        status=true;
    end
end

function nodes=lSelectedNodes(newPath,newNode)
    persistent NODES;
    nodes=NODES;
    if isempty(NODES)||(nargin==0)
        NODES=repmat(struct('path',{},'sid',{},'values',{},'time',{}),0);
    end
    if nargin>0
        NODES(end+1).path=newPath;
        NODES(end).sid=newNode.getSource();
        NODES(end).values=newNode.series.values('V');
        NODES(end).time=newNode.series.time;
    end
end