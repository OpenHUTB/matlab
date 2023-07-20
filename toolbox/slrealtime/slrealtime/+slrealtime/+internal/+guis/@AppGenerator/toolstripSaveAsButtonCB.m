function toolstripSaveAsButtonCB(this)








    origSessionSavedToFile=this.SessionSavedToFile;



    this.SessionSavedToFile=[];




    cancelled=this.saveSession();
    if cancelled

        this.SessionSavedToFile=origSessionSavedToFile;
    end
end
