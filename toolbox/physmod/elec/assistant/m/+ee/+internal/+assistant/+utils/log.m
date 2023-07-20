function out=log(varargin)




    persistent tf
    if isempty(tf)
        tf=false;
    end

    if nargin==1
        state=varargin{1};
        if strcmp(state,'on')
            tf=true;
        elseif strcmp(state,'off')
            tf=false;
        else
            error('unrecognized input argument.')
        end
    end

    out=tf;