function string=getMessageString(identifier,varargin)



    if(nargin==1)
        string=getString(message(sprintf('images:imageRegistration:%s',identifier)));
    elseif(nargin>1)
        string=getString(message(sprintf('images:imageRegistration:%s',identifier),varargin{:}));
    end

end
