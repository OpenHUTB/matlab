





















function this=addBaseline(this,labelIn,baselineFile,varargin)

    if nargin<3
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end

    [index,label]=addInputIndex(this,labelIn);

    fullName=findMatFile(this,baselineFile);

    this.InputData(index).label=label;
    this.InputData(index).baselineFile=fullName;

    if length(varargin)==1
        tolName=findMatFile(this,varargin{1});
        this.InputData(index).toleranceFile=tolName;
    end
end

