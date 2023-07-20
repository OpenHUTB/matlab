function updated=handleUpdateDiagramOrRethrow(this,ME)












    updated=false;

    if isempty(ME),return;end

    function closeCB(e)
        selectedOptionIndex=e.SelectedOptionIndex;
    end

    if strcmp(ME.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')||...
        (~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate'))






        selectedOptionIndex=[];
        if isempty(this.UpdateDiagramSelection)



            uiconfirm(this.getUIFigure(),...
            this.AskToUpdateDiagram_msg,...
            this.AskToUpdateDiagramTitle_msg,...
            'Options',{this.Yes_msg,this.Cancel_msg},...
            'CloseFcn',@(o,e)closeCB(e));
        else



            selectedOptionIndex=this.UpdateDiagramSelection;
        end
        while isempty(selectedOptionIndex)
            pause(0.01);
        end

        switch selectedOptionIndex
        case 1





            set_param(this.SessionSource.ModelName,'SimulationCommand','update');
            updated=true;
        otherwise



        end
    else




        rethrow(ME);
    end
end
