function cancelled=askToSaveSession(this)






    cancelled=false;

    if~this.Dirty,return;end

    function closeCB(e)
        selectedOptionIndex=e.SelectedOptionIndex;
    end



    selectedOptionIndex=[];
    if isempty(this.AskToSaveSessionSelection)



        uiconfirm(...
        this.getUIFigure(),...
        this.AskToSaveSession_msg,...
        this.AskToSaveSessionTitle_msg,...
        'Options',{this.Yes_msg,this.No_msg,this.Cancel_msg},...
        'CloseFcn',@(o,e)closeCB(e));
    else



        selectedOptionIndex=this.AskToSaveSessionSelection;
    end
    while isempty(selectedOptionIndex)
        pause(0.01);
    end

    switch selectedOptionIndex
    case 3





        cancelled=true;

    case 1



        saveCancelled=this.saveSession();
        if saveCancelled




            selectedOptionIndex=[];
            if isempty(this.AskToSaveSessionCancelFilePickerSelection)



                uiconfirm(...
                this.getUIFigure(),...
                this.SessionNotSaved_msg,...
                this.SessionNotSavedTitle_msg,...
                'Options',{this.Continue_msg,this.Abort_msg},...
                'DefaultOption',this.Abort_msg,...
                'CloseFcn',@(o,e)closeCB(e));
            else



                selectedOptionIndex=this.AskToSaveSessionCancelFilePickerSelection;
            end
            while isempty(selectedOptionIndex)
                pause(0.01);
            end

            switch selectedOptionIndex
            case 2





                cancelled=true;
            end
        end
    end









end
