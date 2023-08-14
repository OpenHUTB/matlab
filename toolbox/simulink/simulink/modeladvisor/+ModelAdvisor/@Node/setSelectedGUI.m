function valueStored=setSelectedGUI(this,valueProposed)




    if strcmp(this.getSelectedGUI,'partial')
        PartialBeforeClick=true;
    else
        PartialBeforeClick=false;
    end





    myflag=false;
    if this.NeedToggleForTriState
        valueProposed='unchecked';
        this.NeedToggleForTriState=false;
        myflag=true;
    end

    valueStored=valueProposed;
    if strcmp(valueProposed,'checked')
        newstatus=true;
    else
        newstatus=false;
    end
    this.changeSelectionStatus(newstatus);


    this.updateStates('refreshME');


    if isa(this.MAObj,'Simulink.ModelAdvisor')&&isa(this.MAObj.MAExplorer,'DAStudio.Explorer')
        modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',this.MAObj.MAExplorer);
    end

    if strcmp(this.getSelectedGUI,'partial')
        PartialAfterClick=true;
    else
        PartialAfterClick=false;
    end

    if PartialAfterClick&&PartialBeforeClick&&~myflag
        this.NeedToggleForTriState=true;
    end
