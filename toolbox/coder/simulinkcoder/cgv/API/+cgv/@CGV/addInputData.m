





















function addInputData(this,labelIn,fileName)

    if nargin~=3
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end

    [index,labelOut]=addInputIndex(this,labelIn);


    fullName=findMatFile(this,fileName);


    if length(this.InputData)>=index&&~isempty(this.InputData(index).pathAndName)

        DAStudio.error('RTW:cgv:RepeatedIndexValue',labelOut);
    end


    [~,nameOnly,~]=fileparts(fullName);
    this.InputData(index).nameOnly=nameOnly;
    this.InputData(index).pathAndName=fullName;
    this.InputData(index).label=labelOut;

end

