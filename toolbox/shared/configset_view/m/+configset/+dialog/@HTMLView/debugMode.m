

function out=debugMode(varargin)


    persistent debug
    if isempty(debug)
        debug=false;
    end

    out=debug;

    if nargin==1
        debug=varargin{1};
    end

