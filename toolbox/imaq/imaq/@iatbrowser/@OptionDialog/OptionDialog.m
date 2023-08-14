function this=OptionDialog





    persistent myInstance;
    if isempty(myInstance)
        myInstance=iatbrowser.OptionDialog;
    end

    this=myInstance;
end