function publishMessage(messageId)










    try
        errordlg(getString(message(messageId)));
    catch me
        me.throwAsCaller();
    end
end