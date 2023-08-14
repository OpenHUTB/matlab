function outputValue=evalinContext(varargin)

















    outputValue=[];





















    if(nargout==0)

        evalin('base',varargin{1});

    elseif(nargout==1)

        outputValue=evalin('base',varargin{1});

    end
