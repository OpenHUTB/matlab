function IMTDisplayMessage(message,varargin)
    if nargin==2
        messageProvider=[varargin{1},': '];
    else
        messageProvider='';
    end
    disp([messageProvider,message]);