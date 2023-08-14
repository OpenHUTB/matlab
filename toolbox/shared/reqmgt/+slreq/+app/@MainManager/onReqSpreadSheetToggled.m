

function onReqSpreadSheetToggled(this,~,ed)

    if any(event.hasListener(this.perspectiveManager,'ReqSpreadsheetToggled'))

        this.perspectiveManager.notify('ReqSpreadsheetToggled',ed);
    end

end
