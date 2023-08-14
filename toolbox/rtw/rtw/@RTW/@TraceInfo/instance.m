function out=instance(varargin)




    out=[];
    if nargin==0
        model=bdroot;
    else
        model=varargin{1};
    end

    hTrace=get_param(model,'RTWTraceInfo');
    if isa(hTrace,'RTW.TraceInfo')
        if~strcmp(hTrace.Model,get_param(model,'Name'))
            set_param(model,'RTWTraceInfo',[]);
        else
            out=hTrace;
        end
    end
