function out=instance(varargin)





    out=[];
    narginchk(1,1);
    model=varargin{1};

    hTrace=get_param(model,'HDLTraceInfo');
    if isa(hTrace,'slhdlcoder.TraceInfo')
        if~strcmp(hTrace.Model,get_param(model,'Name'))
            set_param(model,'HDLTraceInfo',[]);
        else
            out=hTrace;
        end
    end
