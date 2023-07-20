function varargout=evalStatementInConfigurationsSection(modelName,assignmentExpression)



    section='Configurations';
    [varargout{1:nargout}]=Simulink.variant.utils.evalExpressionInSection(...
    modelName,assignmentExpression,section);

end
