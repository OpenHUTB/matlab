classdef(Hidden)Presenter<matlab.System




    methods(Static,Abstract)
        dialogExpression=getDialogExpression(parameterExpression);
        parameterExpression=getParameterExpression(dialogExpression);
    end
end