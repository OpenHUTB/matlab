function saveBeforeCloseConfirmation(this,choice,gui)




    switch choice
    case 0

        fileName=this.saveSession(false);


        if~isempty(fileName)
            gui.completeCloseOperation();
        end

    case{1,3}


        gui.completeCloseOperation();

    case 2



    end

end
