function setStatus(obj,newText)




    if obj.useAppContainer
        obj.pStatusLabel.Text=newText;
    else
        obj.pStatus.setText(newText)
    end