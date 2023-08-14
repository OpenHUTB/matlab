function clientH=getClientInstance(blockH)






    clientMap=iofile.FromSpreadsheetBlockUI.ClientMap.getInstance();
    clientH=clientMap.getClientMap(num2str(blockH,32));

end

