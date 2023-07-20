classdef SignalEditorBlockHandler<dependencies.internal.action.refactor.FileParameterHandler





    properties(Constant)
        ParameterName="FileName";
    end

    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.SignalEditorBlockAnalyzer.SignalEditorType.ID);
    end
end
