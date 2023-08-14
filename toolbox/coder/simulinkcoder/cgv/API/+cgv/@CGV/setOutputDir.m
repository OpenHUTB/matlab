

















function this=setOutputDir(this,dir)

    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    cwd=pwd;
    try
        this=setupDir(this,dir);
    catch ME
        msg=DAStudio.message('RTW:cgv:InvalidParam',dir);
        localE=MException('cgv:setOutputDir:InvalidDir',msg);
        ME=addCause(localE,ME);
        throw(ME);
    end
    cd(dir);
    this.OutputDir=pwd;
    cd(cwd);
end

