function closeImportTable(blockH)





    iofile.FromSpreadsheetBlockUI.util.removeCallbacks(blockH);


    listenerMap=iofile.FromSpreadsheetBlockUI.ListenerMap.getInstance();
    listenerMap.removeListener(num2str(blockH,32));


    clientMap=iofile.FromSpreadsheetBlockUI.ClientMap.getInstance();
    clientMap.removeClient(num2str(blockH,32));
    clientMap.removeClientFileName(num2str(blockH,32));
end

