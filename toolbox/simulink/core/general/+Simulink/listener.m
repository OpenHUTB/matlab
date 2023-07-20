function listenr=listener(obj,varargin)












    if isa(obj,'double')
        obj=get_param(obj,'Object');
        if iscell(obj)
            obj=[obj{:}];
        end
    end

    assert(isa(obj,'Simulink.DABaseObject'),...
    'This function should only be called for Simulink/Stateflow objects.');
    for i=1:length(obj)
        listenr(i)=listener(obj(i),varargin{:});
    end
