function onBlockRename(blockH)






    client=iofile.FromSpreadsheetBlockUI.util.getClientInstance(blockH);

    if isempty(client)
        return;
    end


    title=iofile.FromSpreadsheetBlockUI.util.getTitleFromBlockHandle(blockH);

    client.setTitle(title);
end
