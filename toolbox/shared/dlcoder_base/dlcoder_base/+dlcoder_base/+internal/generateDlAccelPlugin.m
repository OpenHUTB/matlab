function varargout=generateDlAccelPlugin(varargin)









    if nargin<1
        return;
    end
    if~ischar(varargin{end})
        return;
    end
    if~strcmp(varargin{end},'tp835d9653_bestej_4437_dlaccelbfd0_dc3f1d27bb78')
        return;
    end


    oldValue=iTurnOnFCForQNet();


    for i=1:coder.internal.evalinArgs(varargin)-1
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end


    report=emlcprivate('callfcn','emlckernel','dlaccel',varargin{1:end-1});


    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError('dlaccel',report);
    end


    iResetFCForQNet(oldValue);

end

function oldValue=iTurnOnFCForQNet()
    oldValue=dlcoderfeature('QNetCodegen');
    dlcoderfeature('QNetCodegen',true);
end

function iResetFCForQNet(oldValue)
    dlcoderfeature('QNetCodegen',oldValue);
end