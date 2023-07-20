




















function initInputData(this,Index)
    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    this.InputData(Index).nameOnly=[];
    this.InputData(Index).pathAndName=[];
    this.InputData(Index).label=[];
    this.InputData(Index).baselineFile=[];
    this.InputData(Index).toleranceFile=[];
    this.OutputData(Index).filename=[];
