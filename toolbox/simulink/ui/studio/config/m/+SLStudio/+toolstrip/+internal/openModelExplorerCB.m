



function openModelExplorerCB(cbinfo)

    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        SLStudio.ToolBars('ModelExplorerSFCB',cbinfo);
    else
        SLStudio.ToolBars('ModelExplorerCB',cbinfo);
    end
end
