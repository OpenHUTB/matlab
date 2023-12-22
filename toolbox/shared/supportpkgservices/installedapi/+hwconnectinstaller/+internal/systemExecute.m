function[status,msg]=systemExecute(command)
    server=hwconnectinstaller.util.SystemExecute.getInstance();
    [status,msg]=server.execute(command);

end
