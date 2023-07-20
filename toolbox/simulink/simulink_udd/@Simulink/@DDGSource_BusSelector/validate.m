function outputArray=validate(this,block)



    hOpenDialog=this.getOpenDialogs;
    if~isempty(hOpenDialog);
        hOpenDialog=hOpenDialog{1};
    end
    if isempty(hOpenDialog)
        this.mOutputSignals=get_param(block.handle,'OutputSignals');
        entriesStr=this.mOutputSignals;
    else
        entriesStr=this.mOutputSignals;
    end
    entries=this.cleanQuestionMarks(this.str2CellArr(entriesStr,','));
    hierarchy=getCachedSignalHierarchy(this,block,false);
    outputArray=validateSelections(this,entries,hierarchy);
end
