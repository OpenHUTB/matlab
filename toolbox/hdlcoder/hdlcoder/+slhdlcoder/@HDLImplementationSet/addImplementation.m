function addImplementation(this,blockLibPath,archName,params,warnOnOverwrite)











    if nargin<5
        warnOnOverwrite=false;
    end

    implInfo=this.getImplInfoForBlockLibPath(blockLibPath);
    if warnOnOverwrite&&~isempty(implInfo)
        warning(message('hdlcoder:engine:tagexists',blockLibPath));
    end

    this.setImplInfoForBlockLibPath(blockLibPath,struct(...
    'Block',blockLibPath,...
    'ArchitectureName',archName,...
    'Parameters',{params},...
    'Instance',[]));
