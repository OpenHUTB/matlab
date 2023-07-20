function refreshFunctionSuggestions(this)

    mdlH=this.configSet.getModel();
    if~isempty(mdlH)
        try
            slcc('parseCustomCode',mdlH);
        catch

            return;
        end
        exportedSyms=slcc('getExportedSymbols',mdlH);
        this.functionSuggestions=exportedSyms.functions;
    end
end