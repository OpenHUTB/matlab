

function reportMessagesOnException(this,mEx_in)



    if(~this.NeedToGenerateHTMLReport)
        return;
    end


    this.addCheck(this.ModelName,'Error',mEx_in);
    try
        this.reportMessages();
    catch mEx
    end
end
