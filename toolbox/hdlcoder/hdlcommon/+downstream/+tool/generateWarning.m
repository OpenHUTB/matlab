function generateWarning(msgObject,cmdDisplay)




    if cmdDisplay
        warning(msgObject);
    else
        warndlg(msgObject.getString,'Warning','modal');
        return;
    end

end