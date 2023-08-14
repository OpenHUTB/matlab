classdef SimMechanicsHandler<dependencies.internal.action.refactor.BlockTypeSpecificParameterHandler




    properties(Constant)
        ParamForBlock=containers.Map(...
        {'mblibv1/Bodies/Body','sm_lib/Body Elements/File Solid'},...
        {'GraphicsFileName','ExtGeomFileName'});
    end

    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.SimMechanicsAnalyzer.SimMechanicsVisualizationType.ID);
    end
end
