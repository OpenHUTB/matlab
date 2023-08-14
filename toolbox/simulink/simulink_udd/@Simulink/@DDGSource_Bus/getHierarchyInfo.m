function getHierarchyInfo(source,block)




    if~isfield(block.UserData,'signalHierarchy')
        ud.oldUserData=block.UserData;
        oldTH=slsvTestingHook('SigHierMxArrayIncludeMessage');
        try
            if(slfeature('SigHierWithMessage')==1)
                slsvTestingHook('SigHierMxArrayIncludeMessage',2);
            end
            ud.signalHierarchy=block.SignalHierarchy;
            if(slfeature('SigHierWithMessage')==1)
                slsvTestingHook('SigHierMxArrayIncludeMessage',oldTH);
            end
        catch ME


            if(slfeature('SigHierWithMessage')==1)
                slsvTestingHook('SigHierMxArrayIncludeMessage',oldTH);
            end
            ud.signalHierarchy=[];
        end


        source.createSignalSelector(oldFormat2NewFormat(source,ud.signalHierarchy));

        ud.selsigviewerlist=handle.listener(source.signalSelector,'TreeChangeEvent',@(h,ev)LocalEnableSelectedAndFind(h,ev));

        if~block.isHierarchyReadonly
            block.UserData=ud;
        end

    end

end

function LocalEnableSelectedAndFind(sigselectorddg,ev)
    dlg=ev.Dialog;
    dlg.getDialogSource.updateSelection(dlg,sigselectorddg);
end

