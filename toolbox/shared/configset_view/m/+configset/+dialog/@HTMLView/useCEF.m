function out=useCEF(varargin)




    persistent cef
    if isempty(cef)
        cef=true;
    end

    out=cef;

    if nargin==1
        cef=varargin{1};
    end

