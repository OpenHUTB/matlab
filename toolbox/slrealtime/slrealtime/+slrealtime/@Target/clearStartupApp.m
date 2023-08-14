function clearStartupApp(this)











    try


        fileOnTarget=strcat(this.StartupDirOnTarget,'/',this.StartupFileName);
        this.deletefile(fileOnTarget);

        notify(this,'StartupAppChanged');
    catch
    end

end
