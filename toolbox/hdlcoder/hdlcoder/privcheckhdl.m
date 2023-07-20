function varargout=privcheckhdl(varargin)




    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if mod(length(varargin),2)==0
        error(message('hdlcoder:makehdl:hdldeprecation',...
        'checkhdl','checkhdl','checkhdl'));
    end

    slhdlcoder.checkLicense;
    [hc,params]=hdlcoderargs(varargin{:});

    if(nargout==1)
        varargout{1}=hc.checkhdl(params);
    elseif(nargout==2)
        [varargout{1},varargout{2}]=hc.checkhdl(params);
    elseif(nargout==3)
        [varargout{1},varargout{2},varargout{3}]=hc.checkhdl(params);
    else
        hc.checkhdl(params);
    end
