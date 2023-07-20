function outputArray=validate(this,block)



    hOpenDialog=this.getOpenDialogs;
    if~isempty(hOpenDialog);
        hOpenDialog=hOpenDialog{1};
    end
    if isempty(hOpenDialog)
        this.mAssignedSignals=get_param(block.handle,'AssignedSignals');
        entriesStr=this.mAssignedSignals;
    else
        entriesStr=this.mAssignedSignals;
    end
    entries=this.cleanQuestionMarks(this.str2CellArr(entriesStr,','));
    hierarchy=getCachedSignalHierarchy(this,block,false);
    outputArray=validateSelections(this,entries,hierarchy);
end
