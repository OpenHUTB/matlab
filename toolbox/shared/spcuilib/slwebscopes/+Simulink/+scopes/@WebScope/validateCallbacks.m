function success=validateCallbacks(~)




    isDSPInstalled=dig.isProductInstalled('DSP System Toolbox');
    isSimScapeInstalled=dig.isProductInstalled('Simscape');


    if~isDSPInstalled&&~isSimScapeInstalled
        success=false;
        return;
    end


    if isSimScapeInstalled
        [success,~]=builtin('license','checkout','Simscape');
        if success
            return
        end
    end



    if isDSPInstalled
        if~isSimScapeInstalled||builtin('license','test','Signal_Blocks')
            [success,~]=builtin('license','checkout','Signal_Blocks');
        end
    end

