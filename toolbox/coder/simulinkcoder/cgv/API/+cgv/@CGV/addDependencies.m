

















function this=addDependencies(this,dependList)
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if nargin<2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    if~iscellstr(dependList)
        stk=dbstack;
        DAStudio.error('RTW:cgv:NotCellArray',stk(1).name);
    end
    for d=1:length(dependList)
        if~exist(dependList{d},'file')
            DAStudio.error('RTW:cgv:CannotOpen',dependList{d});
        end
    end
    this.Dependencies=dependList;
