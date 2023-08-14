




















function this=setWorkingDir(this,dir,varargin)
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    p=inputParser;
    p.addParamValue('overwrite','off',@(x)(ischar(x)&&(strcmpi(x,'on')||strcmpi(x,'off'))))
    p.parse(varargin{:});
    args=p.Results;

    if nargin<2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    cwd=pwd;
    try
        this=setupDir(this,dir);
    catch ME
        msg=DAStudio.message('RTW:cgv:InvalidParam',dir);
        localE=MException('cgv:setWorkingDir:InvalidDir',msg);
        ME=addCause(localE,ME);
        throw(ME);
    end
    cd(dir);
    this.Overwrite=args.overwrite;
    this.WorkDir=pwd;
    cd(cwd);
end

