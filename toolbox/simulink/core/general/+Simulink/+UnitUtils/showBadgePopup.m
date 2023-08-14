function showBadgePopup(model,block,portH)
    unitDiags=Simulink.UnitUtils.getUnitDiagnosticsForPort(model,portH);
    if~isempty(unitDiags)
        popup=Simulink.UnitUtils.Popup(model,Simulink.ID.getSID(block),portH);
        popup.setViolations(unitDiags);
        dlg=DAStudio.Dialog(popup);
        popup.show(dlg);
    end
end
