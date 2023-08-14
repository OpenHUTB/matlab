



























function[index,labelOut]=addInputIndex(this,labelIn)

    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    [index,labelOut]=getInputIndex(this,labelIn);

    if index==0

        index=length(this.InputData)+1;
        if isempty(this.InputData)

            initInputData(this,index);
        end
    else

        if isempty(this.InputData)
            initInputData(this,index);
        elseif length(this.InputData)>=index


            if~isempty(this.InputData(index).label)&&~strcmp(this.InputData(index).label,labelOut)

                moveTo=length(this.InputData)+1;
                this.InputData(moveTo).nameOnly=this.InputData(index).nameOnly;
                this.InputData(moveTo).pathAndName=this.InputData(index).pathAndName;
                this.InputData(moveTo).label=this.InputData(index).label;
                this.InputData(moveTo).baselineFile=this.InputData(index).baselineFile;
                this.InputData(moveTo).toleranceFile=this.InputData(index).toleranceFile;
                this.OutputData(moveTo).filename=[];
                this.OutputData(moveTo).filename=this.OutputData(index).filename;
                initInputData(this,index);
            end
        end

    end
end

