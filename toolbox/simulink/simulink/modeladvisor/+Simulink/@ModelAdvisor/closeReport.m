function closeReport(this)




    if isjava(this.BrowserWindow)
        try
            close(this.BrowserWindow);
        catch E
        end
    end
