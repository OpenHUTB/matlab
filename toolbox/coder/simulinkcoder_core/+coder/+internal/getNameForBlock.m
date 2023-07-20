function[out,varargout]=getNameForBlock(block,varargin)




    opts.system=false;

    for k=1:2:nargin-1
        switch varargin{k}
        case '-system'
            opts.system=varargin{k+1};
        otherwise
            DAStudio.error('Simulink:utility:invalidInputArgs',char(varargin{k}));
        end
    end

    h=get_param(block,'Object');
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    try
        out=h.getRTWName('System',opts.system);
        if nargout>1
            if coder.internal.slcoderReport('generateWebViewOn',bdroot(block))
                varargout{1}=rtwprivate('gethyperlink',block,'JavaScript','on');
            else
                varargout{1}=rtwprivate('gethyperlink',block,'JavaScript','off');
            end
        end
    catch me
        throw(me);
    end
    delete(sess);


