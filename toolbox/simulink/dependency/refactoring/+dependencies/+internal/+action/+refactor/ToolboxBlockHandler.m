classdef ToolboxBlockHandler<dependencies.internal.action.refactor.BlockTypeSpecificParameterHandler




    properties(Constant)
        ParamForBlock=i_getParamForBlock();
    end

    properties(SetAccess=immutable)
        Types=i_getTypes();
    end
end

function toolbox=i_getAndReshapeToolboxInfo()
    import dependencies.internal.analysis.simulink.ToolboxBlocksAnalyzer;
    toolbox=ToolboxBlocksAnalyzer.Toolboxes;
    toolbox=reshape([toolbox{:}],[3,length(toolbox)]);
end

function map=i_getParamForBlock()
    toolbox=i_getAndReshapeToolboxInfo();
    map=containers.Map(toolbox(1,:),toolbox(2,:));
end

function types=i_getTypes()
    toolbox=i_getAndReshapeToolboxInfo();
    types=toolbox(3,:)';
end
