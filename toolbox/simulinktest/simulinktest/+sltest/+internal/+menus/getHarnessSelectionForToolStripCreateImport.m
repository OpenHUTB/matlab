function sel=getHarnessSelectionForToolStripCreateImport(cbinfo)
    pinnedSys=cbinfo.studio.App.getPinnedSystem('systemSelectorTestHarnessManagerAction');
    if~isempty(pinnedSys)&&(isa(pinnedSys,'Simulink.BlockDiagram')||...
        Simulink.harness.internal.isValidHarnessOwnerObject(pinnedSys))

        sel=pinnedSys;
    else



        if slreq.utils.selectionHasMarkup(cbinfo)
            sel=[];
            return;
        end

        sels=cbinfo.getSelection();
        if(numel(sels)==1)&&Simulink.harness.internal.isValidHarnessOwnerObject(sels)



            sel=sels;
        else



            sel=cbinfo.uiObject;
        end
    end

end
