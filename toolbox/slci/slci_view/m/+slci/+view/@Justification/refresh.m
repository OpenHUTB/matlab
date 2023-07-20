



function refresh(obj,id,jsonData)

    decodedJsonForSid=jsondecode(jsonData);
    if obj.hasDialog

        dialog=obj.getDialog;

        setDialogData(dialog,jsonData,decodedJsonForSid);
    else


        tempId=id;
        dialog=slci.view.gui.JustificationDialog(obj.getStudio,tempId);

        setDialogData(dialog,jsonData,decodedJsonForSid);
        obj.setDialog(dialog);
    end

    obj.show();
    dialog.reloadData();
    function setDialogData(dialog,jsonData,decodedJsonForSid)
        dialog.setJsonData(jsonData);
        dialog.setBlockSidforUrl(decodedJsonForSid.BlockSID);
        dialog.setCodeLinesforUrl(decodedJsonForSid.CodeLines);
        dialog.setDataFromUi(decodedJsonForSid.dataFor);
    end
end
