


function hardwareAppOpen=areAnyHardwareTabsOpen(cbinfo)

    hardwareAppOpen=false;
    context=coder.internal.toolstrip.HardwareBoardContextManager.getContext(cbinfo.model.Handle);
    if~isempty(context)
        hardwareAppOpen=true;
    end
end
