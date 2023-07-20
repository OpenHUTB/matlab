function varargout=get(obj,varargin)







    if nargin==1&&nargout==0
        obj.getdisp;
    elseif nargin==2&&nargout<=1
        optionID=varargin{1};
        optionValue=obj.getOptionValue(optionID);
        varargout{1}=optionValue;
    else
        error(message('hdlcommon:workflow:GetOptionValue'));
    end

end
