function this=MessageDialog()





    persistent myInstance;
    if isempty(myInstance)
        myInstance=iatbrowser.MessageDialog;
    end

    this=myInstance;
end