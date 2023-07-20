

function out=uptMode(varargin)



    persistent upt
    if isempty(upt)
        upt=false;
    end

    out=upt;

    if nargin==1
        upt=varargin{1};
    end