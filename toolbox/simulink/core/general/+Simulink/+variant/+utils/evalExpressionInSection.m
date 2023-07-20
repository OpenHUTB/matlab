function varargout=evalExpressionInSection(modelName,expression,section)



    [varargout{1:nargout}]=slprivate('evalinScopeSection',...
    modelName,expression,section,true);
end

