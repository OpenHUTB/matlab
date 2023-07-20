function toolstripSaveCopyAsButtonCB(this)









    origSessionSavedToFile=this.SessionSavedToFile;



    this.SessionSavedToFile=[];




    this.saveSession();



    this.SessionSavedToFile=origSessionSavedToFile;
end
