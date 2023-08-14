function varargout=UtilsCodegenCb(varargin)

%#codegen
    coder.allowpcode('plain');

    switch varargin{1}
    case 'getMessage'
        [varargout{1:nargout}]=getMessage(varargin{2:end});
    otherwise
        error(message('soc:msgs:InternalUnknownCodegenFunction',...
        varargin{1},'UtilsCodegenCb'));
    end
end

function msgObj=getMessage(msgId,varargin)
    coder.extrinsic('message');
    msgObj=message(msgId,varargin{:});
end

