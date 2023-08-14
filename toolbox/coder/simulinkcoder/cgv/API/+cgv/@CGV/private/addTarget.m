















function this=addTarget(this,component,connectivity)

    if nargin~=3
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    switch(component)
    case 'topmodel'
        targetObj=cgvTarget.TargetTopModel(this.ModelName,connectivity);
    case 'modelblock'
        targetObj=cgvTarget.TargetModelBlock(this.ModelName,connectivity);
    otherwise
        DAStudio.error('RTW:cgv:BadTarget',component);
    end
    this.ExecEnv.Obj=targetObj;



