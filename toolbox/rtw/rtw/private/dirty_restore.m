function out=dirty_restore(model,varargin)

















    narginchk(1,2);

    bd=get_param(model,'Object');
    dirty=bd.isDirty('blockDiagram');
    if dirty
        out='on';
    else
        out='off';
    end
    if nargin==1
        out=Simulink.PreserveDirtyFlag(model,'blockDiagram');
    else

        delete(varargin{1});
    end
