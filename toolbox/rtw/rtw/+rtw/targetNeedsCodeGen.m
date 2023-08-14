function varargout=targetNeedsCodeGen(action,varargin)



    persistent TargetNeedsCodeGen;


    if isempty(TargetNeedsCodeGen)
        TargetNeedsCodeGen=false;
    end

    switch(action)
    case 'set'
        tmp=varargin{1};
        if~islogical(tmp)
            DAStudio.error('RTW:utility:invalidArgType','logical');
        end

        TargetNeedsCodeGen=tmp;

    case 'get'
        varargout{1}=TargetNeedsCodeGen;

    case 'reset'
        TargetNeedsCodeGen=false;
    end
