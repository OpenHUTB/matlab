



















function this=setOutputFile(this,labelIn,param)

    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if nargin~=3
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    [~,~,ext]=fileparts(param);
    if isempty(ext)
        param=[param,'.mat'];
    elseif~strcmp(ext,'.mat')
        DAStudio.error('RTW:cgv:BadExtension',param);
    end

    [Index,labelOut]=addInputIndex(this,labelIn);



    if Index==0
        Index=length(this.InputData)+1;
        if isempty(this.InputData)

            initInputData(this,Index);
        end
        this.InputData(Index).label=labelOut;
    end

    this.OutputData(Index).filename=param;

end

