function ret=checkBuildState(action,varargin)

    persistent BuildState

    if isempty(BuildState)
        BuildState=coder.internal.BuildState.IDLE;
    end


    switch lower(action)
    case 'setstate'
        assert(isa(varargin{1},'coder.internal.BuildState'),'value must be a coder.internal.buildState');
        ret=BuildState;
        BuildState=varargin{1};
    case 'getstate'
        ret=BuildState;
    case 'isidlestate'
        ret=(BuildState==coder.internal.BuildState.IDLE);
    case 'isintermediatestate'
        ret=(BuildState==coder.internal.BuildState.BUILDING)||...
        (BuildState==coder.internal.BuildState.CANCELING);
    case 'isterminalstate'
        ret=(BuildState==coder.internal.BuildState.CANCELED)||...
        (BuildState==coder.internal.BuildState.FINISHED)||...
        (BuildState==coder.internal.BuildState.ERROR);
    end
