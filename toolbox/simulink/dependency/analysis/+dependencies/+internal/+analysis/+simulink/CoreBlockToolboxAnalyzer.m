classdef CoreBlockToolboxAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        CoreBlockType=dependencies.internal.graph.Type("CoreBlock");
    end

    properties(Constant,Access=public)
        BlockTypeMap=i_createBlockTypeMap;
    end

    methods

        function this=CoreBlockToolboxAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery;
            query.Block=createParameterQuery('BlockType');
            this.addQueries(query);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            blockTypes=matches.Block.Value;
            blockPaths=matches.Block.BlockPath;
            isKnownType=this.BlockTypeMap.isKey(blockTypes);
            for n=find(isKnownType)
                type=blockTypes{n};
                blockComp=Component.createBlock(node,blockPaths{n},handler.getSID(blockPaths{n}));
                deps(end+1)=dependencies.internal.graph.Dependency.createToolbox(...
                blockComp,this.BlockTypeMap(type),this.CoreBlockType);%#ok<AGROW>
            end
        end

    end

end


function map=i_createBlockTypeMap()



    mapfile=slfullfile(matlabroot,'toolbox','simulink','missing_product_identification','block_type_map.xml');
    assert(~isempty(Simulink.loadsave.resolveFile(mapfile)),'block_type_map.xml not found');
    [blocks,codes]=Simulink.loadsave.findAll(...
    mapfile,...
    '/BlockTypes/BlockType/Name',...
    '/BlockTypes/BlockType/ProductCode');

    blocks=blocks{1};
    codes=codes{1};

    map=containers.Map;
    for n=1:length(blocks)
        baseCodes=string(codes(n).Value);
        if strcmp(baseCodes,'SL')
            continue;
        end

        baseCodes=strsplit(baseCodes,",");

        name=blocks(n).Value;
        product=dependencies.internal.graph.Nodes.createProductNode(baseCodes);
        if~isempty(product)
            map(name)=product;
        end
    end

end
