



function reqEnableAllBreakPointRF(cbinfo,action)

    action.enabled=false;
    if any(strcmp(cbinfo.Context.TypeChain,'ReqTableEditorAutoChartContext'))
        action.enabled=false;
        return;
    end
end
