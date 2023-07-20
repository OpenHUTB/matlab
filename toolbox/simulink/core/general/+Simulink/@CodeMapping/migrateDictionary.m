



function migrateDictionary(mdlH,activeCS,guiEntry,varargin)
    p=inputParser;
    addParameter(p,'noSharedDictionary',false,@islogical);
    parse(p,varargin{:});
    if isa(activeCS,'Simulink.ConfigSetRef')&&~p.Results.noSharedDictionary
        if strcmp(activeCS.getSourceLocation,'Base Workspace')

            f=@()coder.internal.CoderDataStaticAPI.importFromCS(mdlH,activeCS.getRefConfigSet);
            coder.internal.CoderDataStaticAPI.transactionify(mdlH,f,guiEntry);
        else

            f=@()coder.internal.CoderDataStaticAPI.importFromCS(activeCS.getDDName,activeCS.getRefConfigSet);
            coder.internal.CoderDataStaticAPI.transactionify(activeCS.getDDName,f,guiEntry);
        end
    else

        f=@()coder.internal.CoderDataStaticAPI.importFromCS(mdlH,activeCS);
        coder.internal.CoderDataStaticAPI.transactionify(mdlH,f,guiEntry);
    end
end
