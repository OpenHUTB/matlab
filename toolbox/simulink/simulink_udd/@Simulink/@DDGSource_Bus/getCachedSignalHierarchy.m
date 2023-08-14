function signalHierarchy=getCachedSignalHierarchy(~,block,forceRefresh)






    if block.isHierarchyReadonly
        signalHierarchy=block.SignalHierarchy;
    else
        if forceRefresh||~isfield(block.UserData,'signalHierarchy')
            if(slfeature('SigHierWithMessage')==1)
                oldTH=slsvTestingHook('SigHierMxArrayIncludeMessage',2);
                try
                    block.UserData.signalHierarchy=block.SignalHierarchy;
                    slsvTestingHook('SigHierMxArrayIncludeMessage',oldTH);
                catch ME
                    slsvTestingHook('SigHierMxArrayIncludeMessage',oldTH);
                end
            else
                block.UserData.signalHierarchy=block.SignalHierarchy;
            end
        end
        signalHierarchy=block.UserData.signalHierarchy;
    end
