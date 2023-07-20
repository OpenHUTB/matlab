



















function outputData=getOutputData(this,labelIn)

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
    try

        filename=fullfile(this.OutputDir,this.OutputData(Index).filename);
    catch ME
        base_ME=MException('MATLAB:LoadErr',...
        DAStudio.message('RTW:cgv:BadOutputIndex',sprintf('%d',Index)));
        new_ME=addCause(base_ME,ME);
        throw(new_ME);
    end

    if~exist(filename,'file')
        if isempty(this.InputData(Index).pathAndName)
            DAStudio.error('RTW:cgv:BadInputIndex',sprintf('%d',Index));
        end
        DAStudio.error('RTW:cgv:NoOutputData',sprintf('%d',Index));
    end
    outputData=this.OutputData(Index).actual;

end
