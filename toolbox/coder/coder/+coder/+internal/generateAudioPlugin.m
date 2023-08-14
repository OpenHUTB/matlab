function varargout=generateAudioPlugin(varargin)











    if nargin<1
        return;
    end
    if~ischar(varargin{end})
        return;
    end
    if~strcmp(varargin{end},'tp835d9653_bad8_4437_bfd0_dc3f1d27bb78')
        return;
    end


    for i=1:coder.internal.evalinArgs(varargin)-1
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end


    report=emlcprivate('callfcn','emlckernel','audioplugin',varargin{1:end-1});


    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError('audioplugin',report);
    end

