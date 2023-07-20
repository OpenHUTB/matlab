%#codegen
function y=hdleml_add_vec(outtp_ex,varargin)









    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    if nargin==2

        din=varargin{1};
        u=din(1);
        v=din(2);
        y=hdleml_add(u,v,outtp_ex);

    elseif nargin==3

        u=varargin{1};
        v=varargin{2};
        y=hdleml_add(u,v,outtp_ex);

    end
