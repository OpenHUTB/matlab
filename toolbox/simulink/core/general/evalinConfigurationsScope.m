function varargout=evalinConfigurationsScope(model,exprToEval)
















    [varargout{1:nargout}]=slprivate('evalinScopeSection',model,exprToEval,...
    'Configurations',true);
