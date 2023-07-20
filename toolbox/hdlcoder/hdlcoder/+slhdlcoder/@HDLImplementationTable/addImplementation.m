function addImplementation(this,slBlockPath,blockLibPath,classname,params,warnOnOverwrite)












    if nargin<6
        warnOnOverwrite=false;
    end

    implInfo=this.getForTag(slBlockPath);
    if isempty(implInfo)

        implInfo.Path=slBlockPath;
        implInfo.Set=slhdlcoder.HDLImplementationSet();
        this.setForTag(slBlockPath,implInfo);
    end

    implSet=implInfo.Set;
    implSet.addImplementation(blockLibPath,classname,params,warnOnOverwrite);
