function b=dispatch(fevalstr,varargin)


    b=feval(fevalstr,varargin{:});
end