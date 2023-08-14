



















function[signalNames,fileNames]=getMismatches(this,labelIn)

    if this.RunHasBeenCalled==0
        DAStudio.error('RTW:cgv:RunHasNotBeenCalled');
    end

    [Index,labelOut]=getInputIndex(this,labelIn);

    if Index==0
        DAStudio.error('RTW:cgv:BadOutputIndex',labelOut);
    end
    if Index>length(this.InputData)
        DAStudio.error('RTW:cgv:BadInputIndex',sprintf('%d',Index));
    end

    if isempty(this.OutputData(Index).errorPlotFile{1})
        DAStudio.error('RTW:cgv:NoMismatches',labelOut);
    else
        signalNames=this.OutputData(Index).signalName;
        fileNames=this.OutputData(Index).errorPlotFile;
    end
end

