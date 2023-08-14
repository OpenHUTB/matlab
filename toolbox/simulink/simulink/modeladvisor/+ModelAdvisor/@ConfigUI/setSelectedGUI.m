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
    if~isempty(this.ChildrenObj)&&isa(this.MAObj.Toolbar.viewComboBoxWidget,'DAStudio.ToolBarComboBox')...
        &&~strcmp(this.MAObj.Toolbar.viewComboBoxWidget.getCurrentText,DAStudio.message('ModelAdvisor:engine:FullView'))


        for i=1:length(this.ChildrenObj)
            this.ChildrenObj{i}.changeSelectionStatus(newstatus);
        end
    else
        this.changeSelectionStatus(newstatus);
    end


    this.refreshTree;

    if strcmp(this.getSelectedGUI,'partial')
        PartialAfterClick=true;
    else
        PartialAfterClick=false;
    end

    if PartialAfterClick&&PartialBeforeClick&&~myflag
        this.NeedToggleForTriState=true;
    end
