function varargout=evalinGlobalScope(model,exprToEval)















    model=convertStringsToChars(model);
    if(ischar(model))
        load_system(model);
    end

    exprToEval=convertStringsToChars(exprToEval);






    libDD=getAllDictionariesOfLibrary(model);
    if((slfeature('SlModelBroker')>0||slfeature('SLLibrarySLDD')>0)...
        &&~isempty(libDD))
        [varargout{1:nargout}]=slprivate('evalinScopeSectionIncludingLibrary',...
        model,exprToEval,'Global',libDD);
    else
        [varargout{1:nargout}]=slprivate('evalinScopeSection',model,...
        exprToEval,'Global',true);
    end
